function sap_brightupdate(handles,flag,hdl)

clientdata = getappdata(handles.sap_mainfrm,'clientdata');
oldbval = getappdata(handles.sap_mainfrm,'oldbval');
bval = get(handles.sap_slbright,'value');

if oldbval == bval,
    return;
end;
setappdata(handles.sap_mainfrm,'oldbval',bval);

hdllist = [];
if nargin == 3,
    hdllist = hdl;
elseif nargin == 2,
    if bitand(flag,1),
        hdllist = [hdllist;clientdata.type(2).clients(:,2)];
    end;
    if bitand(flag,2),
        hdllist = [hdllist;clientdata.type(1).clients(:,2)];
    end;
else,
    hdllist = [clientdata.type(2).clients(:,2);clientdata.type(1).clients(:,2)];
end;


for i=1:length(hdllist),
    set(hdllist(i),'CData',get(hdllist(i),'CData')*bval/oldbval);
end;