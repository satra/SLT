#include "mex.h"
#include <stdlib.h>
#include <math.h>

#include "vtkStructuredPoints.h"
#include "vtkMarchingCubes.h"

#include "vtkDecimatePro.h"
#include "vtkPolyData.h"
#include "vtkPointData.h"
#include "vtkCellArray.h"
#include "vtkSmoothPolyDataFilter.h"

#include "vtkPolyDataConnectivityFilter.h"
#include "vtkPolyDataMapper.h"

#include "vtkFloatArray.h"

#define NUMBER_OF_FIELDS (sizeof(field_names)/sizeof(*field_names))


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  /* ************** Inputs *******************/
  
  double	*IV;	// Input volume
  double	val;	// Isosurface value
  int		*sz;	// size of volume
  int		interact; // whether or not to interact
  
  /* ************** Outputs *******************/
  // Field data for output structure
  mxArray *out_verts, *out_faces;
  double *out_vertsptr, *out_facesptr;
  
  // field names for output structure
  const char *field_names[] = {"vertices", "faces"};
  
  /* ************** Others ******************* */
  unsigned int n0,numscalars,numverts,numfaces,count,facecount,nidx;
  double pt[3];
  int dims[2] = {1, 1},vert_field,face_field;
  
  // Initialize vtk variables
  vtkFloatArray           *nums = vtkFloatArray::New();
  vtkStructuredPoints     *vol = vtkStructuredPoints::New();

  vtkMarchingCubes        *skinExtractor = vtkMarchingCubes::New();

  vtkDecimatePro          *decimate = vtkDecimatePro::New();
  vtkSmoothPolyDataFilter *smoother = vtkSmoothPolyDataFilter::New();
  vtkPolyDataConnectivityFilter *connector = vtkPolyDataConnectivityFilter::New();

  vtkPoints               *pts;
  vtkCellArray            *polys;
  vtkIdTypeArray          *faces;

  /* Inputs */
  IV = mxGetPr(prhs[0]);
  sz = (int*)mxGetPr(prhs[1]);
  val = *mxGetPr(prhs[2]);
  if (nrhs==4)
    interact = (int)(*mxGetPr(prhs[3]));
  else
    interact = 0;
  
  //mexPrintf("I[%d]\n",Niter);
  
  numscalars = sz[0]*sz[1]*sz[2];
  
  // Convert volume data to floatarray
  nums->SetNumberOfTuples(1);
  nums->SetNumberOfValues(numscalars);
  for(n0=0;n0<numscalars;n0++)
    nums->SetValue(n0,(float)IV[n0]);
  
  // create the volumes
  vol->SetDimensions(sz);
  vol->SetOrigin(0,0,0);
  vol->SetSpacing(1,1,1);
  vol->GetPointData()->SetScalars(nums);
  
  // extract the surface
  skinExtractor->SetInput(vol);
  skinExtractor->ComputeScalarsOff();
  skinExtractor->ComputeGradientsOff();
  skinExtractor->SetValue(0,val);
  
  // decimate the mesh
  decimate->SetInput(skinExtractor->GetOutput());
  decimate->SetInitialFeatureAngle(60);
  decimate->SetMaximumIterations(10);
  decimate->SetMaximumSubIterations(2);
  decimate->PreserveEdgesOn();
  decimate->SetTargetReduction(0.8);
  decimate->SetInitialError(.0002);
  decimate->SetErrorIncrement(.0002);
  
  // smooth the mesh
  smoother->SetInput(decimate->GetOutput());
  smoother->SetNumberOfIterations(10);
  smoother->SetRelaxationFactor(0.1);
  smoother->SetFeatureAngle(60);
  smoother->FeatureEdgeSmoothingOff();
  smoother->BoundarySmoothingOff();
  smoother->SetConvergence(0);
  
  //extract largest connected region to get a manifold surface
  connector->SetInput(smoother->GetOutput());
  connector->SetExtractionModeToLargestRegion();
  connector->Update();

  // Get hold of vertices and faces
  
  // Vertices
  pts = connector->GetOutput()->GetPoints();
  numverts = pts->GetNumberOfPoints();
  out_verts = mxCreateDoubleMatrix(numverts,3,mxREAL);
  out_vertsptr = mxGetPr(out_verts);
  for(n0=0;n0<numverts;n0++)
    {
      pts->GetPoint(n0,pt);
      out_vertsptr[n0] = pt[0];
      out_vertsptr[numverts+n0] = pt[1];
      out_vertsptr[2*numverts+n0] = pt[2];
    }
  
  // Faces
  polys = connector->GetOutput()->GetPolys();
  faces = (vtkIdTypeArray*)polys->GetData();
  
  numfaces = polys->GetNumberOfCells();
  out_faces = mxCreateDoubleMatrix(numfaces,3,mxREAL);
  out_facesptr = mxGetPr(out_faces);
  
  count = 0;
  facecount = 0;
  nidx = 0;
  while(facecount<numfaces)
    {
      nidx = faces->GetValue(count++);
      for(n0=0;n0<nidx;n0++)
	if (n0<3)
	  // Add one to the output as faces are indexed by 0..(n-1)
	  out_facesptr[n0*numfaces+facecount] = faces->GetValue(count++)+1;
	else
	  // Print warning if face contains more than 3 vertices (non-triangular)
	  mexPrintf("Warning: Face[%d] has more than 3 vertices[%d].\n",facecount+1,count++);
      facecount++;
    }
  
  // Create the output structure
  plhs[0] = mxCreateStructArray(2, dims, NUMBER_OF_FIELDS, field_names);
  vert_field = mxGetFieldNumber(plhs[0],"vertices");
  face_field = mxGetFieldNumber(plhs[0],"faces");
  mxSetFieldByNumber(plhs[0],0,vert_field,out_verts);
  mxSetFieldByNumber(plhs[0],0,face_field,out_faces);
  
  
  // Clean up. Delete all vtk objects
  nums->Delete();
  vol->Delete();
  skinExtractor->Delete();
  decimate->Delete();
  smoother->Delete();
  connector->Delete();
}
