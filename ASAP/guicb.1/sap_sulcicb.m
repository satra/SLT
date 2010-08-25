function varargout = sap_sulcicb(h,eventdata,handles,varargin);

cbtype = varargin{1};
switch cbtype,
case 'selectsulci',
    sulcdata = getappdata(handles.sap_mainfrm,'sulcdata');
    sulcdata.num = varargin{2};
    setappdata(handles.sap_mainfrm,'sulcdata',sulcdata);
case 'setnode',
    nodeser = varargin{2};
    nodenum = varargin{3};
    nodedata = getappdata(handles.sap_mainfrm,'nodedata');
    curpos = getappdata(handles.sap_mainfrm,'curpos');
    midpt = getappdata(handles.sap_mainfrm,'midpt');
    if curpos(1)<midpt,
        side = 2;   % left
    else,
        side= 1;    % right
    end;
    nodedata(nodeser,nodenum,side,:) = curpos(1:3);
    if sum(nodedata(nodeser,nodenum,2,:))== 0,
        ltstr = '';
    else,
        ltstr = sprintf('%s',num2str([nodedata(nodeser,nodenum,2,:)]));
    end;
    if sum(nodedata(nodeser,nodenum,1,:))== 0,
        rtstr = '';
    else,
        rtstr = sprintf('%s',num2str([nodedata(nodeser,nodenum,1,:)]));
    end;
    labelstr = strtok(get(h,'Label'),':');    
    str = sprintf('%s:L[%s]R[%s]',labelstr,ltstr,rtstr);
    set(h,'Label',str);
    setappdata(handles.sap_mainfrm,'saveflag',1);
    sap_titlechange(handles.sap_mainfrm,1);
    
    setappdata(handles.sap_mainfrm,'nodedata',nodedata);
case 'btndown',
    slnum = getfield(get(h,'userdata'),'slnum');
    pt = get(h,'currentpoint');
    pt = round(pt(1,1:2));
    curplane = get(handles.sap_planesel,'value');
    curpos = sap_updatecurpos(curplane,slnum,pt);
    setappdata(handles.sap_mainfrm,'curpos',curpos);
    setappdata(handles.sap_mainfrm,'oldbval',1);
    sap_clientmanager('update',[],[],handles,'position',2);
    
    drawmode = getappdata(handles.sap_mainfrm,'drawmode');
    if drawmode,
        acol = load('sap_collist.spt','-MAT');
        cols = acol.collist;
        sulcdata = getappdata(handles.sap_mainfrm,'sulcdata');
        ptlist = uilinedraw;
        %ptlist = sap_drawpts([],cols(sulcdata.num,:),'none');
        if size(ptlist,1) == 1,
            ptlist = [];
        end;
        if isempty(ptlist),
            sap_sulcicb(h,eventdata,handles,'refresh',h);
            return;
        end;

        setappdata(handles.sap_mainfrm,'saveflag',1);
        sap_titlechange(handles.sap_mainfrm,1);
        
        ptlist3d = interpconv2d3(ptlist,curplane,slnum);
        numlists = length(sulcdata.ptlist{sulcdata.num});
        sulcdata.ptlist{sulcdata.num}{numlists+1} = ptlist3d;
        sulcdata.alive{sulcdata.num}(numlists+1) = 1;
        setappdata(handles.sap_mainfrm,'sulcdata',sulcdata);
        sap_sulcicb(h,eventdata,handles,'refresh',h);
    end;
case 'refresh',
    axh = varargin{2};
    if nargin == 6,
        bhitoff = 1;
    else
        bhitoff = 0;
    end;    
    if  getappdata(handles.sap_mainfrm,'showmarker'),
        marker = '.';
    else,
        marker = 'none';
    end;
    sulcdata = getappdata(handles.sap_mainfrm,'sulcdata');
    for j=1:length(axh),
        sap_clientmanager('deleteobj',[],[],handles,'sulchandles',axh(j));
        slnum = getfield(get(axh(j),'userdata'),'slnum');
        lines = getsulclines(sulcdata,slnum,get(handles.sap_planesel,'value'));
        numlines = length(lines);
        if numlines>0,
            lhdl = [];
            axes(axh(j));hold on;
            for i=1:numlines,
                ptlist = lines{i}.ptlist;
                udata.sulcnum = lines{i}.sulcnum;
                udata.idx = lines{i}.idx;
                udata.axh = axh(j);
                udata.mode= 'sulci';
                udata.marker = 0;
                str = 'sap_clientmanager(''buttondowncb'',gcbo,[],guihandles(gcbf),''linesel'');';                
                if bhitoff,
                    lhdl(i) = line(ptlist(:,1),ptlist(:,2),...
                        'linewidth',1,'Erasemode','normal',...
                        'color',lines{i}.col,...
                        'Marker',marker,'HitTest','off',...
                        'linestyle','none',...
                        'userdata',udata);
                else,
                    lhdl(i) = line(ptlist(:,1),ptlist(:,2),...
                        'linewidth',1,'Erasemode','normal',...
                        'color',lines{i}.col,...
                        'Marker',marker,... %'HitTest','off',...
                        'userdata',udata,...
                        'ButtonDownFcn',str,...
                        'UIcontextmenu',handles.sap_drawmenu);
                end;
            end;
            sap_clientmanager('addclient',lhdl,[],handles,'sulcclient',axh(j));
        end;
    end;
case 'delline',
    sulcnum = varargin{2};
    idx = varargin{3};
    sulcdata = getappdata(handles.sap_mainfrm,'sulcdata');
    sulcdata.ptlist{sulcnum}{idx} = [];
    sulcdata.alive{sulcnum}(idx) = 0;
    
    idx1 = find(sulcdata.alive{sulcnum});
    if isempty(idx1),
        sulcdata.ptlist{sulcnum}= {};
        sulcdata.alive{sulcnum}= [];
    else,
        sulcdata.ptlist{sulcnum}= sulcdata.ptlist{sulcnum}(idx1);
        sulcdata.alive{sulcnum}= sulcdata.alive{sulcnum}(idx1);
    end;
    setappdata(handles.sap_mainfrm,'saveflag',1);
    sap_titlechange(handles.sap_mainfrm,1);
    setappdata(handles.sap_mainfrm,'sulcdata',sulcdata);
    sap_sulcicb(h,eventdata,handles,'refresh',h);
case 'showmarker',
    sm = getappdata(handles.sap_mainfrm,'showmarker');
    sm = mod(sm+1,2);
    if sm,
        set(handles.sap_showmarker,'Checked','on');
    else,
        set(handles.sap_showmarker,'Checked','off');
    end;        
    setappdata(handles.sap_mainfrm,'showmarker',sm);
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    sap_sulcicb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1));
end;

function ptlist = interpconv2d3(ptlist,plane,slnum);
ptlist = sap_interp(ptlist);
switch(plane),
case 1,
    ptlist = [slnum*ones(size(ptlist,1),1) ptlist(:,1) ptlist(:,2)];
case 2,
    ptlist = [ptlist(:,1) slnum*ones(size(ptlist,1),1)  ptlist(:,2)];
case 3,
    ptlist = [ptlist(:,1) ptlist(:,2) slnum*ones(size(ptlist,1),1)];
end

function lines = getsulclines(sulcdata,slnum,curplane);
count = 0;
lines = {};
acol = load('sap_collist.spt','-MAT');
cols = acol.collist;
for i=1:length(sulcdata.ptlist),
    col = cols(i,:);
    for j=1:length(sulcdata.ptlist{i}),
        ptlist = sulcdata.ptlist{i}{j};
        switch(curplane),
        case 1,
            ptidx = find(ptlist(:,1)==slnum);
            ptlist = ptlist(:,[2,3]);
        case 2,
            ptidx = find(ptlist(:,2)==slnum);
            ptlist = ptlist(:,[1,3]);
        case 3,
            ptidx = find(ptlist(:,3)==slnum);
            ptlist = ptlist(:,[1,2]);
        end;
        if (length(ptidx)>0),
            count = count+1;
            lines{count}.ptlist = ptlist(ptidx,:);
            lines{count}.sulcnum = i;
            lines{count}.idx = j;
            lines{count}.col = col;
        end;
    end;
end;