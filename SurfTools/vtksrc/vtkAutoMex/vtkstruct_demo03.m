vtkstruct = [];

vtkstruct.filename    = 'vtkIsoSurface.cpp';
vtkstruct.input_type  = 'volume';
vtkstruct.output_type = 'polydata';
vtkstruct.render_output=0;

vtkstruct.pipeline{1}.name = 'vtkMarchingCubes';
vtkstruct.pipeline{end}.parameters{1}.name = 'ComputeScalarsOff';
vtkstruct.pipeline{end}.parameters{end}.value= [];
vtkstruct.pipeline{end}.parameters{end+1}.name = 'ComputeGradientsOff';
vtkstruct.pipeline{end}.parameters{end}.value= [];
vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetValue';
vtkstruct.pipeline{end}.parameters{end}.value= [0 1];
vtkstruct.pipeline{end}.parameters{end}.param= [];

vtkstruct.pipeline{end+1}.name = 'vtkDecimatePro';
vtkstruct.pipeline{end}.parameters{1}.name = 'SetPreserveTopology';
vtkstruct.pipeline{end}.parameters{end}.value= [1];
vtkstruct.pipeline{end}.parameters{end}.param= [];
vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetTargetReduction';
vtkstruct.pipeline{end}.parameters{end}.value= [0.8];
vtkstruct.pipeline{end}.parameters{end}.param= [];
% vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetMaximumSubIterations';
% vtkstruct.pipeline{end}.parameters{end}.value= [2];
% vtkstruct.pipeline{end}.parameters{end+1}.name = 'PreserveEdgesOn';
% vtkstruct.pipeline{end}.parameters{end}.value= [];
% vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetErrorIncrement';
% vtkstruct.pipeline{end}.parameters{end}.value= [.0002];

vtkstruct.pipeline{end+1}.name = 'vtkSmoothPolyDataFilter';
vtkstruct.pipeline{end}.parameters{1}.name = 'SetNumberOfIterations';
vtkstruct.pipeline{end}.parameters{end}.value= [10];
vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetRelaxationFactor';
vtkstruct.pipeline{end}.parameters{end}.value= [0.1];
vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetFeatureAngle';
vtkstruct.pipeline{end}.parameters{end}.value= [60];
vtkstruct.pipeline{end}.parameters{end+1}.name = 'FeatureEdgeSmoothingOff';
vtkstruct.pipeline{end}.parameters{end}.value= [];
vtkstruct.pipeline{end}.parameters{end+1}.name = 'BoundarySmoothingOff';
vtkstruct.pipeline{end}.parameters{end}.value= [];
vtkstruct.pipeline{end}.parameters{end+1}.name = 'SetConvergence';
vtkstruct.pipeline{end}.parameters{end}.value= [0];

vtkstruct.pipeline{end+1}.name = 'vtkPolyDataConnectivityFilter';
vtkstruct.pipeline{end}.parameters{1}.name = 'SetExtractionModeToLargestRegion';
vtkstruct.pipeline{end}.parameters{end}.value= [];
