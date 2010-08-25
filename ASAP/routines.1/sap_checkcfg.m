function sap_checkcfg(AWD)
% SAP_CHECKFG Check the config file
%   SAP_CHECKFG checks to ensure that the configuration file exists and has
%   updated information. If the file doesn't exist, it creates a new file
%   and stores relevant information in it.

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/routines.2/sap_checkcfg.m 2     10/08/02 2:37p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

if exist('config.spt','file'),
    load('config.spt','-MAT');
    
    if ~strcmp(AWD,config.basepath),
        config.basepath = AWD;
    end;
    
    if exist(config.lastwd,'dir')~=7,
        config.lastwd = config.basepath;
    end;
    
    if exist(config.mru2,'file')~=2,
        config.mru2 = '';
    end;
    
    if exist(config.mru1,'file')~=2,
        config.mru1 = config.mru2;
        config.mru2 = '';
    end;
else,
    config.mru2     = '';
    config.mru1     = '';
    config.appname  = 'A.S.A.P';
    config.lastwd   = pwd;
    config.basepath = AWD;
end;

save([AWD filesep 'config.spt'],'config','-MAT');