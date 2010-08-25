/* MEX HEADERS */
#include "mex.h"
#include <stdlib.h>
#include <math.h>

/* VTK HEADERS */

/* VTK polydata input HEADERS */
#include "vtkPolyData.h"
#include "vtkPoints.h"
#include "vtkCellArray.h"
#include "vtkFloatArray.h"

/* VTK pipeline HEADERS */

/* VTK Render HEADERS */

/* VTK polydata render HEADERS */
#include "vtkPolyDataMapper.h"
#include "vtkActor.h"
#include "vtkRenderer.h"
#include "vtkRenderWindow.h"
#include "vtkRenderWindowInteractor.h"

/* MAIN FUNCTION */
void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]){

  /* ************** Inputs *******************/
  double *v;		// Vertices
  unsigned int *f;	// Faces
  
  /* ************** Others ******************* */
  unsigned int nV, nF, i, j;

  // Initialize vtk variables
  vtkPolyData *surf = vtkPolyData::New();
  vtkPoints *sverts = vtkPoints::New();
  vtkCellArray *sfaces = vtkCellArray::New();

  /* Inputs */
  v = mxGetPr(prhs[0]);
  f = (unsigned int*)mxGetPr(prhs[1]);
  
  nV = mxGetM(prhs[0]);
  nF = mxGetM(prhs[1]);
  
  // Load the point, cell, and data attributes.
  for (i=0; i<nV; i++) sverts->InsertPoint(i,v[i],v[nV+i],v[2*nV+i]);
  for (i=0; i<nF; i++) 
    {
      sfaces->InsertNextCell(3);
      for(j=0;j<3;j++)
	sfaces->InsertCellPoint((vtkIdType(f[j*nF+i]-1)));
    }
	
  // We now assign the pieces to the vtkPolyData.
  surf->SetPoints(sverts);
  surf->SetPolys(sfaces);
  sverts->Delete();
  sfaces->Delete();


vtkPolyDataMapper *skinMapper = vtkPolyDataMapper::New();
vtkActor *skin = vtkActor::New();
vtkRenderer *aRenderer = vtkRenderer::New();
vtkRenderWindow *renWin = vtkRenderWindow::New();
vtkRenderWindowInteractor *iren = vtkRenderWindowInteractor::New();

// do rendering stuff to get hold of final object
skinMapper->SetInput(surf);
skinMapper->ScalarVisibilityOff();

skin->SetMapper(skinMapper);

aRenderer->AddActor(skin);
aRenderer->SetBackground(1,1,1);

iren->SetRenderWindow(renWin);

renWin->AddRenderer(aRenderer);
renWin->SetSize(500,500);
renWin->Render();
    
// Start interactive rendering
iren->Start();

skinMapper->Delete();
skin->Delete();
aRenderer->Delete();
renWin->Delete();
iren->Delete();


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
  //pts = pipefinal->GetOutput()->GetPoints();
  pts = surf->GetPoints();
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
  //polys = pipefinal->GetOutput()->GetPolys();
  polys = surf->GetPolys();
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

surf->Delete();
}
