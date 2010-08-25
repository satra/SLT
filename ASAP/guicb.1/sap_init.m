%function sap_init(varargin);
% SAP_INIT 
%  SAP_INIT initializes the A.S.A.P interface

%   Satrajit Ghosh, SpeechLab, Boston University. (c)2001
%   $Revision: 2 $  $Date: 10/08/02 2:36p $

sap_createwksimages(handles);
sap_createcvimages(handles);

setappdata(handles.sap_mainfrm,'saveflag',saveflag);
setappdata(handles.sap_mainfrm,'openflag',openflag);

setappdata(handles.sap_mainfrm,'oldbval',1);
setappdata(handles.sap_mainfrm,'oldmode','browse');
setappdata(handles.sap_mainfrm,'showmarker',1);
setappdata(handles.sap_mainfrm,'drawmode',0);
setappdata(handles.sap_mainfrm,'otlview',0);
setappdata(handles.sap_mainfrm,'sulcview',0);
setappdata(handles.sap_mainfrm,'nodeview',0);
setappdata(handles.sap_mainfrm,'parcview',0);
setappdata(handles.sap_mainfrm,'labelview',0);
setappdata(handles.sap_mainfrm,'autoset',0);

setappdata(handles.sap_mainfrm,'fdata',fdata);
setappdata(handles.sap_mainfrm,'data',imgdata);
setappdata(handles.sap_mainfrm,'curpos',curpos);
setappdata(handles.sap_mainfrm,'offset',offset);
setappdata(handles.sap_mainfrm,'otldata',otldata);
setappdata(handles.sap_mainfrm,'slicemod',slicemod);
setappdata(handles.sap_mainfrm,'sulcdata',sulcdata);
setappdata(handles.sap_mainfrm,'nodedata',nodedata);
setappdata(handles.sap_mainfrm,'parcdata',parcdata);
setappdata(handles.sap_mainfrm,'regdata',regdata);
setappdata(handles.sap_mainfrm,'midpt',round(size(imgdata,1)/2));

set(handles.sap_planesel,'value',curpos(4));
set(handles.sap_slsag,'max',size(imgdata,1),'SliderStep',[1 6]/size(imgdata,1));
set(handles.sap_slcor,'max',size(imgdata,2),'SliderStep',[1 9]/size(imgdata,2));
set(handles.sap_slaxi,'max',size(imgdata,3),'SliderStep',[1 6]/size(imgdata,3));

sap_clientmanager('update',[],[],handles,'position',3,[],1);

config = getappdata(handles.sap_mainfrm,'config');
if ~strcmp(config.mru1,fdata.fullproj),
    config.mru2 = config.mru1;
end;
config.mru1 = fdata.fullproj;

config.lastwd=fdata.projpath;
sap_updatecfg(config,handles);

sap_updatemru(config,handles);

sap_titlechange(handles.sap_mainfrm,saveflag,['A.S.A.P: ' fdata.fullproj]);

sap_updatenodes(handles);

sap_savetimer('init',handles);
%set(handles.sap_mainfrm,'pointer','fullcrosshair');