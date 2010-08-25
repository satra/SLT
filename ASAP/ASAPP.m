function ASAPP(varargin)
% ASAPP Run A.S.A.P.
%  ASAPP launches a new instance of the Automatic Segmentation
%  and Parcellation program (A.S.A.P.)

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Setup globals
global DEBUG

DEBUG = 0;    % Still in beta

% Get filepath to set directoy
fullfilename = which(mfilename);
[AWD,name,xt] = fileparts(fullfilename);

% Initialize directory structure
sap_startup(AWD);

if nargin==1 & strcmp(varargin{1},'init'),
    return;
end;

% Check the configuration file to make sure we are running on
% the same machine
sap_checkcfg(AWD);

%TODO: Show flash
hexist = findobj('Tag','sap_mainfrm');
if hexist,
    msgbox('ASAPP is already running','ASAPP: Launch','modal');
    return;
end;
% Launch gui
h = SAPmainfrm;
set(h,'CloseRequestFcn','sap_prquit;');
centerfig(h);

% Get hold of the object handles
handles = guihandles(h);

colormap(gray);

% Modify the menu
% Create axes and images
sap_addaccel(handles);
sap_modifycontextmenus(handles);

% Load config file and perform relevant updates
load('config.spt','-MAT');
setappdata(handles.sap_mainfrm,'config',config);
sap_updatemru(config,handles);
setappdata(handles.sap_mainfrm,'openflag',0);

if nargin==1,
    if exist(varargin{1},'file'),
        sap_propen(varargin{1},handles.sap_mainfrm);
        set(handles.sap_extractroi,'visible','off');
    end;
end;
        