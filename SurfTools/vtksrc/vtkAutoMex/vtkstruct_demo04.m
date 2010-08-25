vtkstruct = [];

vtkstruct.filename    = 'vtkOpenGL.cpp';
vtkstruct.input_type  = 'polydata';
vtkstruct.output_type = 'polydata';
vtkstruct.render_output=1;

vtkstruct.pipeline = {};

%vtkstruct.pipeline{1}.name = 'vtkPolyDataToPolyDataFilter';
%vtkstruct.pipeline{end}.parameters = {};
