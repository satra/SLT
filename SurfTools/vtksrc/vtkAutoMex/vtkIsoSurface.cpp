/* MEX HEADERS */
#include "mex.h"
#include <stdlib.h>
#include <math.h>

/* VTK HEADERS */

/* VTK volume input HEADERS */
#include "vtkFloatArray.h"
#include "vtkStructuredPoints.h"
#include "vtkPointData.h"

/* VTK polydata output HEADERS */
#include "vtkPolyData.h"
#include "vtkPoints.h"
#include "vtkCellArray.h"
#include "vtkFloatArray.h"

/* VTK pipeline HEADERS */
#include "vtkMarchingCubes.h"
#include "vtkDecimatePro.h"
#include "vtkSmoothPolyDataFilter.h"
#include "vtkPolyDataConnectivityFilter.h"

/* MAIN FUNCTION */
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]){

 /* ************** Inputs *******************/
  
  double	*IV;	// Input volume
  int		*sz;	// size of volume
  
int num_scalars, m0;
  // Initialize vtk variables
  vtkFloatArray           *nums = vtkFloatArray::New();
  vtkStructuredPoints     *vol = vtkStructuredPoints::New();

  /* Inputs */
  IV = mxGetPr(prhs[0]);
  sz = (int*)mxGetPr(prhs[1]);
  
  num_scalars = sz[0]*sz[1]*sz[2];
  
  // Convert volume data to floatarray
  nums->SetNumberOfTuples(1);
  nums->SetNumberOfValues(num_scalars);
  for(m0=0;m0<num_scalars;m0++)
    nums->SetValue(m0,(float)IV[m0]);
  
  // create the volumes
  vol->SetDimensions(sz);
  vol->SetOrigin(0,0,0);
  vol->SetSpacing(1,1,1);
  vol->GetPointData()->SetScalars(nums);

vtkMarchingCubes *pipevar1 = vtkMarchingCubes::New();
pipevar1->SetInput(vol);
pipevar1->ComputeScalarsOff();
pipevar1->ComputeGradientsOff();
pipevar1->SetValue((*mxGetPr(prhs[2])),(*mxGetPr(prhs[3])));
vtkDecimatePro *pipevar2 = vtkDecimatePro::New();
pipevar2->SetInput(pipevar1->GetOutput());
pipevar2->SetPreserveTopology((*mxGetPr(prhs[4])));
pipevar2->SetTargetReduction((*mxGetPr(prhs[5])));
vtkSmoothPolyDataFilter *pipevar3 = vtkSmoothPolyDataFilter::New();
pipevar3->SetInput(pipevar2->GetOutput());
pipevar3->SetNumberOfIterations((10.00f));
pipevar3->SetRelaxationFactor((0.10f));
pipevar3->SetFeatureAngle((60.00f));
pipevar3->FeatureEdgeSmoothingOff();
pipevar3->BoundarySmoothingOff();
pipevar3->SetConvergence((0.00f));
vtkPolyDataConnectivityFilter *pipefinal = vtkPolyDataConnectivityFilter::New();
pipefinal->SetInput(pipevar3->GetOutput());
pipefinal->SetExtractionModeToLargestRegion();
pipefinal->Update();

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

  vtkPoints *pts;
  vtkCellArray *polys;
  vtkIdTypeArray *faces;
  
  // Get hold of vertices and faces
  
  // Vertices
  pts = pipefinal->GetOutput()->GetPoints();
  //pts = surf->GetPoints();
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
  polys = pipefinal->GetOutput()->GetPolys();
  //polys = surf->GetPolys();
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
  plhs[0] = mxCreateStructArray(2, dims, 2, field_names);
  vert_field = mxGetFieldNumber(plhs[0],"vertices");
  face_field = mxGetFieldNumber(plhs[0],"faces");
  mxSetFieldByNumber(plhs[0],0,vert_field,out_verts);
  mxSetFieldByNumber(plhs[0],0,face_field,out_faces);

vol->Delete();
nums->Delete();
pipevar1->Delete();
pipevar2->Delete();
pipevar3->Delete();
pipefinal->Delete();
}
