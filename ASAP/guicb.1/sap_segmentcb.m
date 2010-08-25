function varargout = sap_segmentcb(h,eventdata,handles,varargin);
% SAP_SEGMENTCB Callback during segment edit mode
%   This function responds to OTL related functions, either editing or viewing. For
%   each type of callback which is the first extra argument (varargin{1}), the 
%   functionality and parameters are documented within the switch statement

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/guicb.1/sap_segmentcb.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Setup globals
global DEBUG

% First variable input argument is always the callback type
% This can be:
%   'btndown'
%   'resetotl'
%   'refresh'
%   'delline'
cbtype = varargin{1};

switch cbtype,
case 'btndown',
    % BTNDOWN_CB In this mode the only purpose of the ButtonDownFcn callback 
    % is to draw a new line if the user is in draw mode
    
    % Get draw state information
    drawmode = getappdata(handles.sap_mainfrm,'drawmode');
    
    % Get axis related data stored in the axis itself
    udata = get(h,'userdata');
    slnum = udata.slnum;    % Slice number
    
    if DEBUG,
        sap_status(handles,['segslice: ' num2str(slnum)]);
    end
    
    % If currently in drawmode then allow user to draw on the axis
    if drawmode,
        % Call drawing function
        ptlist = uilinedraw;
        
        % Do not accept a single point in this mode
        if size(ptlist,1) == 1,
            ptlist = [];
        end;
        
        % If no points have been drawn then return
        if isempty(ptlist),
            sap_segmentcb(h,eventdata,handles,'refresh',h);
            return;
        end;
        
        % determine intersections and add pts to drawables
        otldata = getappdata(handles.sap_mainfrm,'otldata');
        
        % If a new line has been drawn change the state of the slice
        % to modified: slicemod = 1
        slicemod = getappdata(handles.sap_mainfrm,'slicemod');
        slicemod(slnum) = 1;
        
        % If no lines on the slice, then add the new line as the first line
        if isempty(otldata(slnum).lines),
            otldata(slnum).lines{1}.ptlist = ptlist;
        else,
            % Check if the new line intersects with any of the original lines
            % Store the intersection information if any.
            % TODO: The structure for storing the lines information can be 
            % modified to be a search tree form so that all comparisons need 
            % not be made.
            numlines = length(otldata(slnum).lines);
            for i=1:numlines,
                tmplist = otldata(slnum).lines{i}.ptlist;
                [xx,yy,ii] = sap_polyintersect(tmplist(:,1),tmplist(:,2),ptlist(:,1),ptlist(:,2));
                numint.ct(i) = size(ii,1);
                numint.ii{i} = ii;
                numint.xx{i} = xx;
                numint.yy{i} = yy;
            end;
            
            % If the drawn line intersects with a single segment at two points
            % then remove the points between the intersection points in the original
            % line and replace it with points between the intersection points of the
            % drawn line. Otherwise just add the new line
            idx = find(numint.ct == 2);
            idx2 = find(numint.ct);
            if ~isempty(idx) & (length(idx2)==1),
                idx = idx(1);
                xx = numint.xx{idx};
                yy = numint.yy{idx};
                ptlistnew = mergelist(otldata(slnum).lines{idx}.ptlist,ptlist,...
                    numint.ii{idx},numint.xx{idx},numint.yy{idx});
                otldata(slnum).lines{idx}.ptlist = ptlistnew;
            else,
                otldata(slnum).lines{numlines+1}.ptlist = ptlist;
            end;                    
        end;
        
        % Set the project modified flag and update the title
        setappdata(handles.sap_mainfrm,'saveflag',1);
        sap_titlechange(handles.sap_mainfrm,1);
        
        % Store the data in the application store
        setappdata(handles.sap_mainfrm,'slicemod',slicemod);        
        setappdata(handles.sap_mainfrm,'otldata',otldata);
        
        % Refresh the axes
        sap_segmentcb(h,eventdata,handles,'refresh',h);
    end;
case 'resetotl',
    % RESETOTL_CB Sometimes deleting a line can cause a significant number of lines
    % to disappear. This provides a quick way of restoring the original outlines 
    % without any modifications for that slice.
    
    % Get the current axes information and then the slice information
    h = gca;
    udata = get(h,'userdata');
    slnum = udata.slnum;
    
    % Load data attributes for this mode
    otldata = getappdata(handles.sap_mainfrm,'otldata');
    slicemod = getappdata(handles.sap_mainfrm,'slicemod');
    
    % reset slicemodification state to 0
    slicemod(slnum) = 0;
    
    % load the original outlines
    % TODO: check if the pathname gets modified if the user is operating
    % on a different directory than original. If so, the user needs to be
    % notified about having the otl file in the same directory as the .spt
    % file
    fdata = getappdata(handles.sap_mainfrm,'fdata');
    try
        load(fdata.otlfile);
    catch
        msg = lasterr;
        sap_status(handles,['RESETOTL Load failed: ' msg],1);
        
        % Return without changing anything
        return;
    end
    
    % Replace the current data with the original data
    otldata(slnum).lines = otl(slnum).lines;
    
    % Update the application store
    setappdata(handles.sap_mainfrm,'slicemod',slicemod);        
    setappdata(handles.sap_mainfrm,'otldata',otldata);
    
    % Refresh the current axis
    sap_segmentcb(h,eventdata,handles,'refresh',h);
case 'refresh',
    % REFRESH_CB This case handles the drawing and updating of axis information
    % Arguments for this case are:
    %   varargin{2} : handles of axes that need to be refreshed
    %   varargin{3} : If this exists, then drawn lines have their hittest property
    %                 set to off.
    
    % Get hold of current position. curpos = [sag_pos, cor_pos, axi_pos, cur_plane]
    curpos = getappdata(handles.sap_mainfrm,'curpos');    
    
    % If we are not in the correct plane we should not be refreshing anything
    if curpos(4) ~=2,
        return;
    end;
    
    % Get list of axes that need to be refreshed
    axh = varargin{2};
    
    % Determine if 'Hittest' property is to be set or not
    if length(varargin) >= 3,
        bhitoff = 1;
    else
        bhitoff = 0;
    end;
    
    % Get OTL information from the application store
    otldata = getappdata(handles.sap_mainfrm,'otldata');
    
    % Refresh each of the desired axes
    for j=1:length(axh),
        
        % delete the current segment lines in this specific axis
        sap_clientmanager('deleteobj',[],[],handles,'seghandles',axh(j));
        
        % Get the slice number corresponding to the axis
        slnum = getfield(get(axh(j),'userdata'),'slnum');
        
        % Get total number of lines that need to be drawn
        numlines = length(otldata(slnum).lines);
        if numlines>0,
            lhdl = [];
            axes(axh(j));hold on;
            for i=1:numlines,
                % Get hold of the points in the line
                ptlist = otldata(slnum).lines{i}.ptlist;
                
                % Create a data structure for each line that holds the
                % following info
                udata.slnum = slnum;    % slice number
                udata.idx = i;          % lineorder
                udata.axh = axh(j);     % axis handle
                udata.mode= 'segment';  % which mode drew the object
                udata.marker = 0;       % marker ???TODO: Find what this does
                
                % Set a callback for each line object to be a lineselected (linesel) callback
                % which is routed through the client manager which decides what to do with
                % it. Store this callback as a string and add it to the lines callback function
                % during construction
                str = 'sap_clientmanager(''buttondowncb'',gcbo,[],guihandles(gcbf),''linesel'');';                
                
                if bhitoff, % No modification, hence no callback
                    lhdl(i) = line(ptlist(:,1),ptlist(:,2),...
                        'Parent',axh(j),...
                        'Marker','none','HitTest','off',...
                        'userdata',udata,...
                        'Color','y');
                else, % modification allowed, hence callback and context menu
                    lhdl(i) = line(ptlist(:,1),ptlist(:,2),...
                        'Parent',axh(j),...
                        'Marker','none',... %'HitTest','off',...
                        'userdata',udata,...
                        'ButtonDownFcn',str,...
                        'UIcontextmenu',handles.sap_drawmenu,...
                        'Color','g');
                end;
            end;
            hold off;
            
            % Add the array of handles as a new client object of type 'segclient'
            % to the current axis
            sap_clientmanager('addclient',lhdl,[],handles,'segclient',axh(j));
        end;
    end;
    
    % TODO: Determine if this is necessary
    refresh(gcbf);
case 'delline',
    % DELLINE_CB This switch removes a selected line from the data store
    % varargin{2} : Slice number
    % varargin{3} : line index
    
    slnum = varargin{2};    % slice number
    idx = varargin{3};      % line index
    
    % Get OTL data from app store
    otldata = getappdata(handles.sap_mainfrm,'otldata');
    
    % Get indices of lines to keep
    keepidx = setdiff(1:length(otldata(slnum).lines),idx); 
    
    % remove the line from the slice
    if isempty(keepidx),
        otldata(slnum).lines = {};
    else,
        otldata(slnum).lines = otldata(slnum).lines([keepidx]);
    end;
    
    % update slice modification state
    slicemod = getappdata(handles.sap_mainfrm,'slicemod');
    slicemod(slnum) = 1;
    
    setappdata(handles.sap_mainfrm,'saveflag',1);
    sap_titlechange(handles.sap_mainfrm,1);
    
    setappdata(handles.sap_mainfrm,'slicemod',slicemod);        
    setappdata(handles.sap_mainfrm,'otldata',otldata);
    
    % refresh the current axis
    sap_segmentcb(h,eventdata,handles,'refresh',h);
end;

function newlist = mergelist(xy1,xy2,ii,xx,yy)
% MERGELIST Subfunction which computes the result of two lines intersecting at 
%   exactly two points.
%   xy1,xy2: old line points
%   ii  : intersection structure returned from polyxpoly
%   xx,yy: new line points

%   TODO: Don't seem to remember exact details of the function, but the basic idea
%   was to select the appropriate set of points based loosely on the indices of the
%   segments at the intersections. Primarily it keeps the segment from the new drawn
%   line.

min2  = min(ii(:,2));
max2  = max(ii(:,2));

if ii(1,2)>ii(2,2),
    idx = max2:-1:min2+1;
else,
    idx = min2+1:max2;
end;

if size(xy1,1)/2<abs(diff(ii(:,1))),
    newlist = [xx(1) yy(1);...
            xy2(idx,:);xx(2) yy(2);xy1(ii(2,1):-1:ii(1,1)+1,:);xx(1) yy(1);];
else,
    newlist = [xy1(1:ii(1,1),:);xx(1) yy(1);...
            xy2(idx,:);xx(2) yy(2);...
            xy1(ii(2,1)+1:end,:)];
end;