vtkstruct = [];

vtkstruct.filename    = 'vtkDecimate.cpp';
vtkstruct.input_type  = 'polydata';
vtkstruct.output_type = 'polydata';
vtkstruct.parameterize= 1;
vtkstruct.render_output = 0;

vtkstruct.pipeline{1}.name = 'vtkDecimate';
vtkstruct.pipeline{end}.parameters{1}.name = 'SetPreserveTopology';
vtkstruct.pipeline{end}.parameters{end}.value= [1];
vtkstruct.pipeline{end}.parameters{end}.type = 'int';

vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetTargetReduction';
vtkstruct.pipeline{end}.parameters{end}.value= [0.1];
vtkstruct.pipeline{end}.parameters{end}.param= [];

 vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetMaximumIterations';
 vtkstruct.pipeline{end}.parameters{end}.value= [5];
% vtkstruct.pipeline{end}.parameters{end}.param= [];
 vtkstruct.pipeline{end}.parameters{end}.type = 'int';

% vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetErrorIncrement';
% vtkstruct.pipeline{end}.parameters{end}.value= [0.001];
% vtkstruct.pipeline{end}.parameters{end}.param= [];

vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetMaximumFeatureAngle';
vtkstruct.pipeline{end}.parameters{end}.value= [180];
% vtkstruct.pipeline{end}.parameters{end}.param= [];

vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetMaximumError';
vtkstruct.pipeline{end}.parameters{end}.value= [0.1];

vtkstruct.pipeline{end}.parameters{end+1}.name = 'PreserveEdgesOff';
vtkstruct.pipeline{end}.parameters{end}.value= [];

vtkstruct.pipeline{end+1}.name = 'vtkPolyDataConnectivityFilter';
vtkstruct.pipeline{end}.parameters{1}.name = 'SetExtractionModeToLargestRegion';
vtkstruct.pipeline{end}.parameters{end}.value= [];

