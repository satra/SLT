function sap_updatecfg(config,handles)

setappdata(handles.sap_mainfrm,'config',config);
save([config.basepath filesep 'config.spt'],'config','-MAT');