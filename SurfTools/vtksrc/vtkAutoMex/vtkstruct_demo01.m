vtkstruct = [];

vtkstruct.filename    = 'vtkReorient.cpp';
vtkstruct.input_type  = 'polydata';
vtkstruct.output_type = 'polydata';
vtkstruct.parameterize= 1;
vtkstruct.render_output = 0;

vtkstruct.pipeline{1}.name = 'vtkPolyDataNormals';
vtkstruct.pipeline{end}.parameters{1}.name = 'ConsistencyOn';
vtkstruct.pipeline{end}.parameters{end}.value= [];
vtkstruct.pipeline{end}.parameters{end+1}.name = 'SplittingOff';
vtkstruct.pipeline{end}.parameters{end}.value= [];
vtkstruct.pipeline{end}.parameters{end+1}.name = 'NonManifoldTraversalOn';
vtkstruct.pipeline{end}.parameters{end}.value= [];
