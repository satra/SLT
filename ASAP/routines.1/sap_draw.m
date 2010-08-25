function ptlist = sap_draw(ptlist,color,marker)

BtnDnFcn = get(gcbf,'WindowButtonDownFcn');
BtnMotFcn= get(gcbf,'WindowButtonMotionFcn');
BtnUpFcn = get(gcbf,'WindowButtonUpFcn');
inter   = get(gcbf,'Interruptible');

str = sprintf('sap_drawcb(''down'');');
set(gcbf,'WindowButtonDownFcn');
str = sprintf('sap_drawcb(''move'');');
set(gcbf,'WindowButtonMotionFcn');
str = sprintf('sap_drawcb(''up'');');
set(gcbf,'WindowButtonUpFcn');
set(gcbf,'Interruptible','on');

hdl = guihandles(gcbf);
setappdata(hdl.sap_mainfrm,'done',0);
setappdata(hdl.sap_mainfrm,'ptlist',[]);

sap_drawcb('init',ptlist,color,marker);
while ~(getappdata(hdl.sap_mainfrm,'done')),
    drawnow;
end;

set(gcbf,'WindowButtonDownFcn',BtnDnFcn);
set(gcbf,'WindowButtonMotionFcn',BtnMotFcn);
set(gcbf,'WindowButtonUpFcn',BtnUpFcn);
set(gcbf,'Interruptible',inter);

ptlist = getappdata(hdl.sap_mainfrm,'ptlist');
rmappdata(hdl.sap_mainfrm,'ptlist');
rmappdata(hdl.sap_mainfrm,'done');

