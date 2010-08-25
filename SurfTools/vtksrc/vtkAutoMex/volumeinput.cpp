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
