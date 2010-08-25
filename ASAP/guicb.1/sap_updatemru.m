function sap_updatemru(config,handles)

set(handles.sap_mru1,'Label',config.mru1,'visible','on');
if isempty(config.mru1),
    set(handles.sap_mru1,'visible','off');
end;

set(handles.sap_mru2,'Label',config.mru2,'visible','on');
if isempty(config.mru2),
    set(handles.sap_mru2,'visible','off');
end;
