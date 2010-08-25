function sap_posupdate(handles,flag,opt,init)

% flag = workspace(2) or cv(1) or none(0) or both(3)
% opt = which cv
% init = 1 axis image

clientdata = getappdata(handles.sap_mainfrm,'clientdata');
data = getappdata(handles.sap_mainfrm,'data');
curpos = getappdata(handles.sap_mainfrm,'curpos');
oldbval = getappdata(handles.sap_mainfrm,'oldbval');
bval = get(handles.sap_slbright,'value');
setappdata(handles.sap_mainfrm,'oldbval',bval);
curaxs = gca;

%sap_status(handles,['posupdate: f-' num2str(flag)]);

if bitand(flag,2),
    if nargin>2 & ~isempty(opt),
        switch opt,
        case 1,
            cdata = data(curpos(opt),:,:);
            set(handles.sap_txtsag,'String',num2str(curpos(1)));
        case 2,
            cdata = data(:,curpos(2),:);
            set(handles.sap_txtcor,'String',num2str(curpos(2)));
        case 3,
            cdata = data(:,:,curpos(3));
            set(handles.sap_txtaxi,'String',num2str(curpos(3)));
        end;
        
        set(clientdata.type(2).clients(opt,2),'CData',bval/oldbval*squeezeu8(cdata)');
        if nargin==4,
            axis(clientdata.type(2).clients(opt,1),'image');
        end;
    else,
        cdata{1} = data(curpos(1),:,:);
        cdata{2} = data(:,curpos(2),:);
        cdata{3} = data(:,:,curpos(3));
        for i=1:size(clientdata.type(2).clients,1),
            set(clientdata.type(2).clients(i,2),'CData',bval/oldbval*squeezeu8(cdata{i})');
            if nargin == 4,
                axis(clientdata.type(2).clients(i,1),'image');
            end;
        end;
        set(handles.sap_slsag,'Value',curpos(1));
        set(handles.sap_txtsag,'String',num2str(curpos(1)));
        set(handles.sap_slcor,'Value',curpos(2));
        set(handles.sap_txtcor,'String',num2str(curpos(2)));
        set(handles.sap_slaxi,'Value',curpos(3));
        set(handles.sap_txtaxi,'String',num2str(curpos(3)));
    end;
end;

if bitand(flag,1),
    numimages = size(clientdata.type(1).clients,1);
    sliceno = curpos(curpos(4));
    val1 = fix(numimages/2);
    val2 = numimages-val1-1;
    
    idx1 = sliceno-val1;
    idx2 = sliceno+val2;
    if (sliceno-val1)<1,
        idx1 = 1;
        idx2 = numimages;
    elseif (sliceno+val2)>size(data,curpos(4)),
        idx2 = size(data,curpos(4));
        idx1 = idx2-numimages+1;
    end;
    %[idx1 idx2 size(data)]
    
    for i=idx1:idx2, %1:length(clientdata.type(1)),
        clnum = i-idx1+1;
        switch (curpos(4)),
        case 1,
            set(clientdata.type(1).clients(clnum,2),'CData',bval/oldbval*squeezeu8(data(i,:,:))');
        case 2,
            set(clientdata.type(1).clients(clnum,2),'CData',bval/oldbval*squeezeu8(data(:,i,:))');
        case 3,
            set(clientdata.type(1).clients(clnum,2),'CData',bval/oldbval*squeezeu8(data(:,:,i))');
        end;
        imgdata = get(clientdata.type(1).clients(clnum,2),'CData');
        imgdata(end:-1:(end-4),1:15) = 65535*sap_num2bmp(i);
        set(clientdata.type(1).clients(clnum,2),'CData',imgdata);
        udata = get(clientdata.type(1).clients(clnum,1),'userdata');
        udata.slnum = i;
        set(clientdata.type(1).clients(clnum,1),'userdata',udata);
        if nargin == 4,
            axis(clientdata.type(1).clients(clnum,1),'image');
        end;
    end;
end;

if isfield(clientdata,'pointhdl'),
    if ~isempty(clientdata.pointhdl),
        set(clientdata.pointhdl,'Erasemode','normal');
        delete(clientdata.pointhdl);
        clientdata.pointhdl = [];
    end;
end;
if strcmp(get(handles.sap_showpos,'Checked'),'on'),
    %sap_drawpos
    
    % update the cv
    count =0;
    for i=1:3,
        count = count+1;
        axes(clientdata.type(2).clients(i,1));hold on;
        switch i,
        case 1,
            clientdata.pointhdl(count) = plot(curpos(2),curpos(3),'r+','Hittest','off');
        case 2,
            clientdata.pointhdl(count) = plot(curpos(1),curpos(3),'r+','Hittest','off');
        case 3,
            clientdata.pointhdl(count) = plot(curpos(1),curpos(2),'r+','Hittest','off');
        end;
    end;
    
    for i=1:size(clientdata.type(1).clients,1),
        count = count+1;
        axes(clientdata.type(1).clients(i,1));hold on;
        switch curpos(4),
        case 1,
            clientdata.pointhdl(count) = plot(curpos(2),curpos(3),'r+','Hittest','off');
        case 2,
            clientdata.pointhdl(count) = plot(curpos(1),curpos(3),'r+','Hittest','off');
        case 3,
            clientdata.pointhdl(count) = plot(curpos(1),curpos(2),'r+','Hittest','off');
        end;
    end;
    % return focus to curpos
    axes(curaxs);
end;
setappdata(handles.sap_mainfrm,'clientdata',clientdata);