#include "mex.h"
#include <stdlib.h>
#include <math.h>

//#include "vtkDecimate.h"
#include "vtkDecimatePro.h"
#include "vtkPolyData.h"
#include "vtkPoints.h"
#include "vtkCellArray.h"
#include "vtkFloatArray.h"
#include "vtkPolyDataMapper.h"

#include "vtkSmoothPolyDataFilter.h"
#include "vtkPolyDataConnectivityFilter.h"

#define NUMBER_OF_FIELDS (sizeof(field_names)/sizeof(*field_names))


void mexFunction(int nlhs,       mxArray *plhs[],
				 int nrhs, const mxArray *prhs[])
{
	/* ************** Inputs *******************/
	double *v;			// Vertices
	unsigned int *f;	// Faces
	double	factor1,factor2;	// Parameters: Reduction Factor
	int		interact;	// whether or not to interact

	/* ************** Outputs *******************/
	// Field data for output structure
	mxArray *out_verts, *out_faces;
	double *out_vertsptr, *out_facesptr;

	// field names for output structure
	const char *field_names[] = {"vertices", "faces"};


	/* ************** Others ******************* */
	unsigned int nV, nF, i, j;
	unsigned int n0,numscalars,numverts,numfaces,count,facecount,nidx;
	double pt[3];
    int dims[2] = {1, 1},vert_field,face_field;

	// Initialize vtk variables
	vtkPolyData *surf = vtkPolyData::New();
	vtkPoints *sverts = vtkPoints::New();
	vtkCellArray *sfaces = vtkCellArray::New();
	vtkSmoothPolyDataFilter *smoother = vtkSmoothPolyDataFilter::New();
	//vtkDecimate	*decimate = vtkDecimate::New();
	vtkDecimatePro	*decimate = vtkDecimatePro::New();
	vtkPolyDataConnectivityFilter *connector = vtkPolyDataConnectivityFilter::New();

	vtkPoints *pts;
	vtkCellArray *polys;
	vtkIdTypeArray *faces;

	/* Inputs */
	v = mxGetPr(prhs[0]);
	f = (unsigned int*)mxGetPr(prhs[1]);
	factor1 = *mxGetPr(prhs[2]);
	factor2 = *mxGetPr(prhs[3]);


	nV = mxGetM(prhs[0]);
	nF = mxGetM(prhs[1]);

	if (nrhs==5)
		interact = (int)(*mxGetPr(prhs[4]));
	else
		interact = 0;
	
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
	sverts->Delete();
	surf->SetPolys(sfaces);
	sfaces->Delete();
	
	// decimate the mesh
	//decimate->SetInput(skinExtractor->GetOutput());
	decimate->SetInput(surf);

	decimate->SetPreserveTopology(int(factor2));
	decimate->SetTargetReduction(factor1);
	//decimate->SetMaximumCost(factor1);
	//decimate->SetMaximumCollapsedEdges(int(factor2));
	//decimate->SetInitialFeatureAngle(45);
	//decimate->SetMaximumIterations(20);
	//decimate->SetMaximumSubIterations(2);
	//decimate->PreserveEdgesOn();
	//decimate->SetInitialError(.0002);
	//decimate->SetErrorIncrement(.0005);

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
	polys = connector->GetOutput()->GetPolys();
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
	plhs[0] = mxCreateStructArray(2, dims, NUMBER_OF_FIELDS, field_names);
    vert_field = mxGetFieldNumber(plhs[0],"vertices");
    face_field = mxGetFieldNumber(plhs[0],"faces");
	mxSetFieldByNumber(plhs[0],0,vert_field,out_verts);
	mxSetFieldByNumber(plhs[0],0,face_field,out_faces);


	// Clean up. Delete all vtk objects
	surf->Delete();
	decimate->Delete();
	smoother->Delete();
	connector->Delete();
}
