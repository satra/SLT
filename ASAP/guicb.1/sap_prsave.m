function sap_prsave(bAutoSave,varargin)
% SAP_PRSAVE 
%  SAP_PRSAVE saves a new or modified A.S.A.P project

%   Satrajit Ghosh, SpeechLab, Boston University. (c)2001
%   $Revision: 2 $  $Date: 10/08/02 2:36p $

if nargin<1,
    bAutoSave = 0;
end;
if nargin==2,
    figh = varargin{1};
else,
    figh = gcbf;
end;

handles = guihandles(figh);

% till saveflag is available for everything
%if getappdata(handles.sap_mainfrm,'saveflag'),
fdata   =   getappdata(handles.sap_mainfrm,'fdata');
imgdata =   getappdata(handles.sap_mainfrm,'data');
curpos  =   getappdata(handles.sap_mainfrm,'curpos');
offset  =   getappdata(handles.sap_mainfrm,'offset');
otldata =   getappdata(handles.sap_mainfrm,'otldata');
slicemod=   getappdata(handles.sap_mainfrm,'slicemod');
sulcdata=   getappdata(handles.sap_mainfrm,'sulcdata');
nodedata=   getappdata(handles.sap_mainfrm,'nodedata');
parcdata=   getappdata(handles.sap_mainfrm,'parcdata');
regdata =   getappdata(handles.sap_mainfrm,'regdata');

if ~bAutoSave,
    save(fdata.fullproj,'-MAT','fdata','imgdata','curpos','offset',...
        'otldata','slicemod','sulcdata','nodedata','parcdata','regdata');
    setappdata(handles.sap_mainfrm,'saveflag',0);
    sap_titlechange(handles.sap_mainfrm,0);
else,
    save([fdata.fullproj,'.bak'],'-MAT','fdata','curpos','offset',...
        'otldata','slicemod','sulcdata','nodedata','parcdata','regdata');
end;

%end;