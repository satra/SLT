function sap_startup(AWD)
% MAT_STARTUP Create the directory structure and add it temporarily to path

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/sap_startup.m 2     10/08/02 2:36p Satra $

% $NoKeywords: $

global RELEASE 

% Initialize directory structure
basedir = [AWD filesep];

if RELEASE,
    addpath(genpath(basedir));
else,
    addpath([basedir]);
    addpath([basedir 'data.1']);
    addpath([basedir 'gui.1']);
    addpath([basedir 'guicb.1']);
    addpath([basedir 'routines.1']);
    addpath([basedir 'preprocess.1']);
    addpath([basedir '..' filesep 'RAT2' filesep 'ASAPpreprocess']);
end;
