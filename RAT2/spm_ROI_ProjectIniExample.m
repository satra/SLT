function spm_ROI_ProjectIni
% spm_ROI_ProjectIni Project initialization function
%
% If a file with the same name as a spm_ROI project
% exist in the same directory with a matlab extension 
% (if the project file is 'myproject.roi' an initialization
% file should be named 'myproject.m') that file is run
% each time a project is opened. This allows placing
% the definition of most of the project fields there
% (in case you find difficult or tiresome to do it
% using the provided user interface).
%
% This file is an example defining a design matrix for 
% a block design experiment. You can use this as a base
% for more complex initialization files. 
%
% Modify the lines below as needed. 
%

%%%%%%%%%%%%%%%%%%%%%%%
% Your definitions here
%%%%%%%%%%%%%%%%%%%%%%%

blocklength=15;                             % block length (scans)
block=sin(linspace(0,pi,blocklength))';     % half-sine block
silence=zeros(blocklength,1);

% note: this is a single run design, multiple runs for each subject are averaged, all the subjets share this design, session-specific effects are added by spm_ROI
Design=[ ...
    block   ,   silence ; 
    silence ,   silence ;
    silence ,   block ;
    silence ,   silence ;
    block   ,   silence ; 
    silence ,   silence ;
    silence ,   block ;
    silence ,   silence ;
    block   ,   silence ; 
    silence ,   silence ;
    silence ,   block ;
    silence ,   silence ];
    
Contrast={ ...
    [1,   0] ;
    [0,   1] ;
    [1/2, 1/2] ;
    [1,   -1] ...
    };

ContrastName={ ...
    'Block 1' ;
    'Block 2' ;
    'Block Sum' ;
    'Block Diff' ...
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Project initialization functions here
% (see spm_ROI_input for the definition of several project fields)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spm_ROI_input('model.RepetitionTime',...
    2 ...           % TR (seconds)
    );

spm_ROI_input('model.DesignMatrix',...
    {Design} ...    % Design matrix (use multiple variables if they are different for each subject)
    );

spm_ROI_input('model.ConcatRuns',...
    0 ...           % (0:average 1:concatenate) if multiple runs for each subject exist
    );

spm_ROI_input('model.ContrastVector',...
    {Contrast} ...  % Contrast vectors (use multiple variables if they are different for each subject)
    );

spm_ROI_input('model.ContrastVectorName',...
    ContrastName ... 
    );

spm_ROI_input('model.ContrastSpatialVector',...
    '1' ...         % functional form of spatial contrast vector
    );
