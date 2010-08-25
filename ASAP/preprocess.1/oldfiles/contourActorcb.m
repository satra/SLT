function contourActorcb(callback_type)

persistent down_pt

handles = guihandles(gcf);
imgmask = getappdata(handles.contourActor,'imgmask');

switch callback_type,
case 'down',
    pt = get(handles.dummyaxs,'CurrentPoint');
    pt = round(pt(1,1:2));
    
    % Get click type
    button = get(handles.contourActor,'Selectiontype');
    if strcmp(button,'alt'),    % right click
        val = imgmask(pt(2),pt(1));
    else,
        down_pt = pt;
        val = getappdata(handles.contourActor,'val');
        if isempty(val),
            val = mean(imgmask(:));
        end;
    end;
    setappdata(handles.contourActor,'val',val);
    set(handles.contourActor,'WindowButtonMotionfcn','contourActorcb(''move'');');
    set(handles.contourActor,'WindowButtonUpfcn','contourActorcb(''up'');');
    set(handles.curval,'string',['current val: [' num2str(val) ']']);
case 'move'
    pt = get(handles.dummyaxs,'CurrentPoint');
    pt = round(pt(1,1:2));
    button = get(handles.contourActor,'Selectiontype');
    if strcmp(button,'alt'),    % right click
        val = imgmask(pt(2),pt(1));
    else,
        diff_y = pt(2)-down_pt(2);
        val = getappdata(handles.contourActor,'val');
        val = max(val-diff_y*0.001*max(imgmask(:)),0);
        down_pt = pt;
        [c,h] = contour(imgmask,[val val],'y');
        set(h,'hittest','off');
        setappdata(handles.contourActor,'val',val);
    end;
    set(handles.curval,'string',['current val: [' num2str(val) ']']);
case 'up',
    val = getappdata(handles.contourActor,'val');
    set(handles.contourActor,'WindowButtonMotionfcn','');
    set(handles.contourActor,'WindowButtonUpfcn','');
    [c,h] = contour(imgmask,[val val],'y');
    set(h,'hittest','off');
    set(handles.curval,'string',['current val: [' num2str(val) ']']);
end;