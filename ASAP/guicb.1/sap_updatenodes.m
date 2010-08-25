function sap_updatenodes(handles)

nodedata = getappdata(handles.sap_mainfrm,'nodedata');
nodehdl  = getappdata(handles.sap_mainfrm,'nodehdl');

nodes = sap_nodelist;

for nodeser=1:length(nodes), % old stuff --> 1:length(nodehdl),
    for nodenum=nodes(nodeser).did(:)',
        h = nodehdl{nodes(nodeser).sid}{nodes(nodeser).id(nodenum)};
        if sum(nodedata(nodes(nodeser).sid,nodes(nodeser).id(nodenum),2,:))== 0,
            ltstr = '';
        else,
            ltstr = sprintf('%s',num2str([nodedata(nodes(nodeser).sid,nodes(nodeser).id(nodenum),2,:)]));
        end;
        if sum(nodedata(nodes(nodeser).sid,nodes(nodeser).id(nodenum),1,:))== 0,
            rtstr = '';
        else,
            rtstr = sprintf('%s',num2str([nodedata(nodes(nodeser).sid,nodes(nodeser).id(nodenum),1,:)]));
        end;
        labelstr = strtok(get(h(1),'Label'),':');    
        str = sprintf('%s:L[%s]R[%s]',labelstr,ltstr,rtstr);
        set(h,'Label',str);
    end;
end;
