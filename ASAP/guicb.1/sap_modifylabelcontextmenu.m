function sap_modifylabelcontextmenu(handles,labels,id);

kids = get(handles.sap_smartlabel,'children');
if ~isempty(kids),
    delete(kids);
end;

% modify label context menu
for i=1:length(labels),
    str = sprintf('sap_clientmanager(''sap_labelcb'',gcbo,[],guihandles(gcbf),''setlabel'',%d,''%s'')',id(i),labels{i});
    udata.col = rand(1,3);
    udata.id = id(i);
    labelhdl(i) = uimenu('Parent',handles.sap_smartlabel,...
        'Label',labels{i},...
        'Callback',str,...
        'userdata',udata);
end;
setappdata(handles.sap_mainfrm,'labelhdl',labelhdl);