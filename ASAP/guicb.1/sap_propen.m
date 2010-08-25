function sap_propen(projname,varargin)
% SAP_PROPEN 
%  SAP_PROPEN opens an existing A.S.A.P project

%   Satrajit Ghosh, SpeechLab, Boston University. (c)2001
%   $Revision: 2 $  $Date: 10/08/02 2:36p $

if nargin==2,
    figh = varargin{1};
else,
    figh = gcbf;
end;

handles = guihandles(figh);

if getappdata(handles.sap_mainfrm,'openflag'),
    if ~sap_prclose,
        return;
    end;
end;

config = getappdata(handles.sap_mainfrm,'config');
if nargin>0,
    load(projname,'-MAT');
    [path,nm,ext] = fileparts(projname);
    pname = path;
    fname = [nm ext];
else,
    pdir = pwd;
    cd(config.lastwd);
    [fname,pname] = uigetfile({'*.spt','A.S.A.P Project Files'},'A.S.A.P: Open Project File');
    cd(pdir);
    
    if fname == 0,
        return;
    end;
    load('-MAT',[pname fname])
end;

% Update project location details so that files created on one machine can
% be used on another
if ~strcmp(fdata.fullproj,fullfile(pname,fname)),
    fdata.projfile = fname;
    fdata.projpath = pname;
    fdata.fullproj = fullfile(pname,fname);
end;
[srcpath,srcname,xt] = fileparts(fdata.fullsrc);
fdata.fullsrc  = fullfile(pname,[srcname,xt]);
fdata.filename = [srcname,xt];
[srcpath,srcname,xt] = fileparts(fdata.otlfile);
fdata.otlfile  = fullfile(pname,[srcname,xt]);
fdata.pathname = pname;

saveflag = 0;
openflag = 1;
sap_init;