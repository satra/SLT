function varargout = sap_parccb(h,eventdata,handles,varargin);

cbtype = varargin{1};
switch cbtype,
case 'btndown',
    drawmode = getappdata(handles.sap_mainfrm,'drawmode');
    if drawmode,
        ptlist = uilinedraw;
        %ptlist = sap_drawpts([],'r','none');
        if size(ptlist,1) == 1,
            ptlist = [];
        end;
        if isempty(ptlist),
            sap_parccb(h,eventdata,handles,'refresh',h);
            return;
        end;
        % determine intersections and add pts to drawables
        parcdata = getappdata(handles.sap_mainfrm,'parcdata');
        slnum = getfield(get(h,'userdata'),'slnum');
        
        slicemod = getappdata(handles.sap_mainfrm,'slicemod');
        slicemod(slnum) = 1;
        setappdata(handles.sap_mainfrm,'saveflag',1);
        sap_titlechange(handles.sap_mainfrm,1);

        numlines = length(parcdata(slnum).lines);
        parcdata(slnum).lines{numlines+1}.ptlist = ptlist;
        parcdata(slnum).alive(numlines+1) = 1;
        setappdata(handles.sap_mainfrm,'parcdata',parcdata);
        setappdata(handles.sap_mainfrm,'slicemod',slicemod);
        sap_parccb(h,eventdata,handles,'refresh',h);
    end;
case 'refresh',
    curpos = getappdata(handles.sap_mainfrm,'curpos');    
    if curpos(4) ~=2,
        return;
    end;
    axh = varargin{2};
    if nargin == 6,
        bhitoff = 1;
    else
        bhitoff = 0;
    end;
    parcdata = getappdata(handles.sap_mainfrm,'parcdata');
    for j=1:length(axh),
        sap_clientmanager('deleteobj',[],[],handles,'parchandles',axh(j));
        slnum = getfield(get(axh(j),'userdata'),'slnum');
        numlines = length(parcdata(slnum).lines);
        if numlines>0,
            lhdl = [];
            axes(axh(j));hold on;
            for i=1:numlines,
                ptlist = parcdata(slnum).lines{i}.ptlist;
                udata.slnum = slnum;
                udata.idx = i;
                udata.axh = axh(j);
                udata.mode= 'parc';
                udata.marker = 0;
                str = 'sap_clientmanager(''buttondowncb'',gcbo,[],guihandles(gcbf),''linesel'');';      
                if bhitoff,
                    lhdl(i) = line(ptlist(:,1),ptlist(:,2),...
                        'Parent',axh(j),...
                        'Marker','none','HitTest','off',...
                        'userdata',udata,...
                        'Color','g');
                else,
                    lhdl(i) = line(ptlist(:,1),ptlist(:,2),...
                        'Parent',axh(j),...
                        'Marker','none',... %'HitTest','off',...
                        'userdata',udata,...
                        'ButtonDownFcn',str,...
                        'UIcontextmenu',handles.sap_drawmenu,...
                        'Color','g');
                end;
            end;
            sap_clientmanager('addclient',lhdl,[],handles,'parcclient',axh(j));
        end;
    end;
case 'delline',
    slnum = varargin{2};
    idx = varargin{3};
    parcdata = getappdata(handles.sap_mainfrm,'parcdata');
    parcdata(slnum).lines{idx}.ptlist = [];
    parcdata(slnum).alive(idx) = 0;
    idx = find(parcdata(slnum).alive);
    if isempty(idx),
        parcdata(slnum).lines = {};
    else,
        parcdata(slnum).lines = parcdata(slnum).lines([idx]);
        parcdata(slnum).alive = parcdata(slnum).alive(idx);
    end;
    setappdata(handles.sap_mainfrm,'saveflag',1);
    sap_titlechange(handles.sap_mainfrm,1);
    setappdata(handles.sap_mainfrm,'parcdata',parcdata);
    sap_parccb(h,eventdata,handles,'refresh',h);
end;