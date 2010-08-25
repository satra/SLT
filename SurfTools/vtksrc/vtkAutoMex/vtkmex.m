function vtkmex(vtkstruct)
% VTKMEX(VTKSTRUCT) takes a VTK pipeline defined in VTKSTRUCT and
% creates a C++ mex file and corresponding matlab file. The C++
% file can then be compiled with the mex compiler.
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

fid = fopen(vtkstruct.filename,'wt');

fprintf(fid,'/* MEX HEADERS */\n');
writemexheaders(fid);

fprintf(fid,'\n/* VTK HEADERS */\n');
writevtkheaders(fid,vtkstruct);

fprintf(fid,'\n/* MAIN FUNCTION */\n');
input_vars = writemexmain(fid,vtkstruct);

fclose(fid);

fprintf('Writing matlab wrapper.\n');
writematlabwrapper(vtkstruct,input_vars);

function writemexheaders(fid)
fprintf('Writing MEX headers\n');
fprintf(fid,'#include "mex.h"\n');
fprintf(fid,'#include <stdlib.h>\n');
fprintf(fid,'#include <math.h>\n');

function writevtkheaders(fid,vtkstruct)
% Write vtkstruct.input_type headers
switch(vtkstruct.input_type)
    case 'image',
    case 'volume',
        fprintf('Writing volume input headers\n');
        fprintf(fid,'\n/* VTK volume input HEADERS */\n');
        fprintf(fid,'#include "vtkFloatArray.h"\n');
        fprintf(fid,'#include "vtkStructuredPoints.h"\n');
        fprintf(fid,'#include "vtkPointData.h"\n');
    case 'polydata',
        fprintf('Writing polydata input headers\n');
        fprintf(fid,'\n/* VTK polydata input HEADERS */\n');
        fprintf(fid,'#include "vtkPolyData.h"\n');
        fprintf(fid,'#include "vtkPoints.h"\n');
        fprintf(fid,'#include "vtkCellArray.h"\n');
        fprintf(fid,'#include "vtkFloatArray.h"\n');
end
if ~strcmp(vtkstruct.input_type,vtkstruct.output_type),
    switch(vtkstruct.output_type)
        case 'image',
        case 'volume',
        case 'polydata',
            fprintf('Writing polydata output headers\n');
            fprintf(fid,'\n/* VTK polydata output HEADERS */\n');
            fprintf(fid,'#include "vtkPolyData.h"\n');
            fprintf(fid,'#include "vtkPoints.h"\n');
            fprintf(fid,'#include "vtkCellArray.h"\n');
            fprintf(fid,'#include "vtkFloatArray.h"\n');
    end
end

fprintf(fid,'\n/* VTK pipeline HEADERS */\n');
for i=1:length(vtkstruct.pipeline)
    fprintf(fid,'#include "%s.h"\n',vtkstruct.pipeline{i}.name);
end

if vtkstruct.render_output,
    fprintf(fid,'\n/* VTK Render HEADERS */\n');
    switch(vtkstruct.output_type)
        case 'image',
        case 'volume',
        case 'polydata',
            fprintf('Writing polydata output headers\n');
            fprintf(fid,'\n/* VTK polydata render HEADERS */\n');
            fprintf(fid,'#include "vtkPolyDataMapper.h"\n');
            fprintf(fid,'#include "vtkActor.h"\n');
            fprintf(fid,'#include "vtkRenderer.h"\n');
            fprintf(fid,'#include "vtkRenderWindow.h"\n');
            fprintf(fid,'#include "vtkRenderWindowInteractor.h"\n');
    end
end;

function input_vars = writemexmain(fid,vtkstruct)
fprintf('Writing main function\n');
fprintf(fid,'void mexFunction(int nlhs,mxArray *plhs[],int nrhs,const mxArray *prhs[]){\n');

switch (vtkstruct.input_type),
    case 'image',
    case 'volume',
        vtkinsertfile(fid,'volumeinput.cpp');
        varname = 'vol';
        input_vars(1).name = 'volume';
        input_vars(2).name = 'size';
    case 'polydata',
        % Write polydata input segment
        vtkinsertfile(fid,'polydatainput.cpp');
        varname = 'surf';
        input_vars(1).name = 'vertices';
        input_vars(2).name = 'faces';
end  

% Write main pipeline
param_ct = length(input_vars);
if isfield(vtkstruct,'parameterize')
    paramall = vtkstruct.parameterize;
else,
    paramall = 0;
end

listvar = {};
for i=1:length(vtkstruct.pipeline),
    varnameold = varname;
    if i==length(vtkstruct.pipeline),
        varname = 'pipefinal';
    else
        varname = sprintf('pipevar%d',i);
    end
    listvar{i} = varname;
    pipename = vtkstruct.pipeline{i}.name;
    fprintf(fid,'%s *%s = %s::New();\n',pipename,varname, ...
        pipename);
    if i==1,
        fprintf(fid,'%s->SetInput(%s);\n', ...
            varname,varnameold);
    else,
        fprintf(fid,'%s->SetInput(%s->GetOutput());\n', ...
            varname,varnameold);
    end
    for j=1:length(vtkstruct.pipeline{i}.parameters),
        paramname = vtkstruct.pipeline{i}.parameters{j}.name;
        paramval  = vtkstruct.pipeline{i}.parameters{j}.value;
        fprintf(fid,sprintf('%s->%s(',varname,paramname));
        for k=1:length(paramval),
	    if isfield(vtkstruct.pipeline{i}.parameters{j},'type'),
		typestr = vtkstruct.pipeline{i}.parameters{j}.type;
	    else
		typestr = '';
	    end
            if paramall | isfield(vtkstruct.pipeline{i}.parameters{j},'param'),
                if k==1,
                    fprintf(fid,'%s(*mxGetPr(prhs[%d]))',typestr,param_ct);
                else
                    fprintf(fid,',%s(*mxGetPr(prhs[%d]))',typestr,param_ct);
                end
                param_ct = param_ct + 1;
                input_vars(param_ct).name = sprintf('%s%02d%02d',paramname,i,k);
            else
                if k==1,
                    fprintf(fid,'%s(%.2ff)',typestr,paramval(k));
                else
                    fprintf(fid,',%s(%.2ff)',typestr,paramval(k));
                end
            end
        end
        fprintf(fid,');\n');
    end
end

if ~isempty(vtkstruct.pipeline),
    % Render output
    if ~vtkstruct.render_output,
        fprintf(fid,'%s->Update();\n',varname);
    else,
        switch (vtkstruct.output_type),
            case 'image',
            case 'volume',
            case 'polydata',
                % Write polydata render segment
                vtkinsertfile(fid,'polydatarender.cpp');
        end
    end
else,
    if vtkstruct.render_output,
        switch (vtkstruct.output_type),
            case 'image',
            case 'volume',
            case 'polydata',
                % Write polydata render segment
                vtkinsertfile(fid,'polydatarender_nopipeline.cpp');
        end
    end
end

if ~isempty(vtkstruct.pipeline),
    switch (vtkstruct.output_type),
        case 'image',
        case 'volume',
        case 'polydata',
            % Write polydata output segment
            vtkinsertfile(fid,'polydataoutput.cpp');
    end  
else,
    switch (vtkstruct.output_type),
        case 'image',
        case 'volume',
        case 'polydata',
            % Write polydata output segment
            vtkinsertfile(fid,'polydataoutput_nopipeline.cpp');
    end  
end    
% clean up vtk objects
switch (vtkstruct.input_type),
    case 'image',
    case 'volume',
        fprintf(fid,'vol->Delete();\n');
        fprintf(fid,'nums->Delete();\n');
    case 'polydata',
        fprintf(fid,'surf->Delete();\n');
end  
for i=1:length(listvar),
    fprintf(fid,'%s->Delete();\n',listvar{i});
end
if vtkstruct.render_output,
    switch (vtkstruct.output_type),
        case 'image',
        case 'volume',
        case 'polydata',
%             fprintf(fid,'skinMapper->Delete();\n');
%             fprintf(fid,'skin->Delete();\n');
%             fprintf(fid,'aRenderer->Delete();\n');
%             fprintf(fid,'renWin->Delete();\n');
%             fprintf(fid,'iren->Delete();\n');
    end
end

fprintf(fid,'}\n');

function vtkinsertfile(fid,filename)
fid1 = fopen(filename,'rt');
data = fread(fid1,inf);
fclose(fid1);
fprintf(fid,'\n');
fwrite(fid,data);
fprintf(fid,'\n');


function writematlabwrapper(vtkstruct,input_vars)
[pth,nm,xt] = fileparts(vtkstruct.filename);
fid = fopen([pth,nm,'.m'],'wt');
fprintf(fid,'function output = %s(%s',nm,input_vars(1).name);
for i=2:length(input_vars),
    fprintf(fid,',...\n\t\t%s',input_vars(i).name);
end
fprintf(fid,')\n');
fprintf(fid,'%% %s is an autogenerated mex wrapper that describes the arguments\n',upper(nm));
fprintf(fid,'%% that are needed for the mex file operation.\n');
switch (vtkstruct.input_type),
    case 'image',
    case 'volume',
    case 'polydata',
     fprintf('Writing polydata input related information\n');
     fprintf(fid,'%% For polydata input:\n');
     fprintf(fid,'%% vertices type=double\n');
     fprintf(fid,'%% faces    type=int32 and min(faces)==1 not 0\n');
end  
fclose(fid);
