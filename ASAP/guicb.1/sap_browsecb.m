function varargout = sap_browsecb(h,eventtype,handles,varargin);

cbtype = varargin{1};
switch cbtype,
case 'btndown',
    pt = get(h,'currentpoint');
    pt = round(pt(1,1:2));
    udata = get(h,'userdata');
    curpos = sap_updatecurpos(get(handles.sap_planesel,'value'),udata.slnum,pt);
    setappdata(handles.sap_mainfrm,'curpos',curpos);
    setappdata(handles.sap_mainfrm,'oldbval',1);
    sap_clientmanager('update',[],[],handles,'position',2);
case 'showpos',
    state = get(h,'checked');
    if strcmp(state,'on'),
        set(h,'checked','off');
        sap_clientmanager('update',[],[],handles,'position',0);
    else,
        set(h,'checked','on');
        sap_clientmanager('update',[],[],handles,'position',0);
    end;
end;
