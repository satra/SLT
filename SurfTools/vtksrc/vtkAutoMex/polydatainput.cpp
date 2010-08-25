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
