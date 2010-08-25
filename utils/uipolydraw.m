function varargout = uipolydraw(varargin)
% UIPOLYDRAW Drawing and editing of polygons
%   This function allows one to draw and edit polygons on any axis. Assumes the axis
%   is set to axis image. Only one instance of this should be used at a given time.
%   The usage is as follows:
%   - Left click adds a point or selects an already existing point.
%   - Left click and drag moves the added or selected point
%   - right clicking on a point removes the point
%   - backspace/delete also removes the last point
%   - enter/return finishes editing

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/uipolydraw.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

% The persistent variables can be changed to a userdata structure
%persistent pts idx axs fig dummyaxs state
%persistent xrange yrange bclose line_hdl

switch(nargin),
case 0,
    % When no input data is provided
    if nargout<1,
        error('incorrect number of output arguments');
    end;
    varargout(1) = {uipolydraw('ptsgiven',[])};
otherwise,
    if ~(isnumeric(varargin{1}) | ischar(varargin{1})),
        error('unknown argument');
    end;
    switch(lower(varargin{1})),
    case 'ptsgiven'
        % Points were provided
        if nargout<1,
            error('incorrect number of output arguments');
        end;
        % get hold of figure and axis information
        d.fig = gcf;
        if strcmp(get(d.fig,'handlevisibility'),'callback')
            d.axs = gcbo;
        else,
            d.axs = gca;
        end;
        
        d.state = uisuspend(d.fig);

        dbstate = get(d.fig,'Doublebuffer');
        if ~strcmp(dbstate,'on'),
            set(d.fig,'Doublebuffer','on');
        end;
        d.dbstate = dbstate;
        
        d.xrange = get(d.axs,'Xlim');
        d.yrange = get(d.axs,'Ylim');
        
        % create a dummy axis to work above the original axis
        % This seems to be a great way to modify objects without interfering
        % with the original axes
        d.dummyaxs = copyobj(d.axs,d.fig);
        delete(get(d.dummyaxs,'children'));
        set(d.dummyaxs,...
            'color','none',...
            'Drawmode','fast',...
            'Xlimmode','manual',...
            'Ylimmode','manual',...
            'nextplot','replacechildren',...
            'Tag','dummyaxs');

        if 0,
        d.dummyaxs = axes(...
            'Parent',d.fig,...
            'position',get(d.axs,'position'),...
            'dataaspectratio',get(d.axs,'dataaspectratio'),...
            'plotboxaspectratio',get(d.axs,'plotboxaspectratio'),...
            'color','none',...
            'Xlim',get(d.axs,'Xlim'),...
            'Ylim',get(d.axs,'Ylim'),...
            'Ydir',get(d.axs,'Ydir'),...
            'Drawmode','fast',...
            'Xlimmode','manual',...
            'Ylimmode','manual',...
            'nextplot','replacechildren',...
            'Tag','dummyaxs');
        end
        
        % get hold of the points
        d.pts = varargin{2};
        d.pts = sub_removeredundantpts(d.pts,1,d.xrange,d.yrange);
        
        d.bclose = 1; % create polygon
        d.bnochange = 0; % allow changes pts added/deleted
        d.bconvex = 0; % allow non-convex polygons
        
        % to take care of matlab indexing
        d.line_hdl = line(...
            'Xdata',[],...
            'Ydata',[]);
        
        % set the properties of the line
        d.linetag = sprintf('Linetag%f.%f',rand,rand);
        set(d.line_hdl,...
            'tag',d.linetag,...
            'Parent',d.dummyaxs,...
            'marker','s',...
            'color','r',...
            'markeredgecolor','r',...
            'Hittest','off');
        
        set(d.line_hdl,'userdata',d);
        sub_drawpoints(d.line_hdl,d.pts,d.bclose);

        % Set the required callbacks
        set(d.dummyaxs,'Buttondownfcn',sprintf('uipolydraw(''btndown'',''%s'');',d.linetag));
        set(d.fig,'WindowButtonUpFcn','');
        set(d.fig,'WindowButtonMotionFcn','');
        set(d.fig,'KeyPressFcn',sprintf('uipolydraw(''keypress'',''%s'');',d.linetag));
        set(d.fig,'Pointer', 'crosshair');
        
        if nargin>2,
            numpairs = (nargin-2)/2;
            for i=1:numpairs,
                uipolydraw(varargin{(2*i+1):(2*i+2)},d.linetag);
            end;
        end;

        try
            waitfor(d.dummyaxs, 'UserData', 'Completed');
        catch
            error('Unknown error occurred');
        end
        
        d = get(d.line_hdl,'userdata');
        
        % delete the extr axes
        delete(d.dummyaxs);
        
        % restore the state of the figure
        uirestore(d.state);
        
        set(d.fig,'doublebuffer',d.dbstate);
        
        % return the pts that were created
        varargout(1) = {d.pts};
        
    case 'btndown',
        % Evaluates when a button is pressed in the invisible axes
        d = get(findobj('tag',varargin{2}),'userdata');
        
        % Get the current point
        pt = get(d.axs,'CurrentPoint');
        pt = pt(1,1:2);
        
        % Set bounds on points such that they remain within the normalized
        % rectangle
        pt = sub_setbounds(pt,d.xrange,d.yrange) ;
        if d.bconvex,
            if size(d.pts,1)>3,
                bkeep = sub_keepconvex(d.pts,pt);
                if ~bkeep,
                    return;
                end;
            end;
        end;
        
        % Insert the point in the appropriate location and return the
        % index of the location
        [d.pts,d.idx] = sub_delegatept(d.pts,pt,d.xrange,d.yrange,d.bclose,d.bnochange);
        
        % Get click type
        button = get(d.fig,'Selectiontype');
        if strcmp(button,'alt'),    % right click removes the point
            if ~d.bnochange,
                d.pts = [d.pts(1:(d.idx-1),:);d.pts((d.idx+1):end,:)];
            end;
        else
            d.pts(d.idx,:) = pt;
            set(d.fig,'WindowButtonMotionFcn',sprintf('uipolydraw(''move'',''%s'');',d.linetag));
        end;
        
        sub_drawpoints(d.line_hdl,d.pts,d.bclose);
        
        % set the button up function
        set(d.fig,'WindowButtonUpFcn',sprintf('uipolydraw(''btnup'',''%s'');',d.linetag));
        set(d.line_hdl,'userdata',d);
    case 'move',
        % Evaluates movement of the mouse. This callback is called only when
        % the mouse button is pressed and moved
        d = get(findobj('tag',varargin{2}),'userdata');
        
        % Get the current point in the figure where the mouse is
        % and convert it with respect to the axes
        
        pt = get(d.axs,'CurrentPoint');
        pt = pt(1,1:2);
        
        % Set the bounds on the point
        pt = sub_setbounds(pt,d.xrange,d.yrange) ;
        if d.bconvex,
            if size(d.pts,1)>3,
                bkeep = sub_keepconvex(d.pts,pt,d.idx);
                if ~bkeep,
                    return;
                end;
            end;
        end;
        
        % update the value of the point
        d.pts(d.idx,:) = pt;
        
        % redraw the line
        sub_drawpoints(d.line_hdl,d.pts,d.bclose);
        set(d.line_hdl,'userdata',d);
    case 'btnup',
        % when the button is released
        d = get(findobj('tag',varargin{2}),'userdata');
        
        % Restore the callbacks for the figure
        set(d.fig,'WindowButtonUpFcn','');
        set(d.fig,'WindowButtonMotionFcn','');
        
        % Remove redundant points from the function
        % See the function 'removeredundantpts' for more details
        d.pts = sub_removeredundantpts(d.pts,d.idx,d.xrange,d.yrange);
        
        % update the line
        sub_drawpoints(d.line_hdl,d.pts,d.bclose);
        set(d.line_hdl,'userdata',d);
    case 'keypress',
        d = get(findobj('tag',varargin{2}),'userdata');
        key = get(d.fig, 'CurrentCharacter');
        switch key
        case {char(8), char(127)}  % delete and backspace keys
            if d.bnochange,
                return;
            end;
            switch(size(d.pts,1)),
            case 0,
            case 1,
                d.pts = [];
                set(d.line_hdl,'XData',[],'YData',[]);    
            otherwise,
                switch(d.idx),
                case 1,
                    d.pts = d.pts(2:end,:);
                    d.idx = 2;
                case size(d.pts,1),
                    d.pts = d.pts(1:(end-1),:);
                    d.idx = d.idx-1;
                otherwise,
                    d.pts = [d.pts(1:(d.idx-1),:);d.pts((d.idx+1):end,:)];
                end;
                sub_drawpoints(d.line_hdl,d.pts,d.bclose);
            end;
            set(d.line_hdl,'userdata',d);
        case {char(13), char(3)}   % enter and return keys
            % return control to line after waitfor
            set(d.dummyaxs, 'UserData', 'Completed');
        end
    case 'bclose', % closed polygon or line
        d = get(findobj('tag',varargin{3}),'userdata');
        d.bclose = varargin{2};
        set(d.line_hdl,'userdata',d);        
    case 'bnochange', % allow/disallow addition/deletion of points
        d = get(findobj('tag',varargin{3}),'userdata');
        d.bnochange = varargin{2};
        set(d.line_hdl,'userdata',d);        
    case 'bconvex', % convex polygon or not
        d = get(findobj('tag',varargin{3}),'userdata');
        d.bconvex = varargin{2};
        set(d.line_hdl,'userdata',d);        
    case 'marker',
        d = get(findobj('tag',varargin{3}),'userdata');
        set(d.line_hdl,'marker',varargin{2});        
    otherwise,
        error('Unknown argument');
    end
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          SUBFUNCTIONS                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [pts,idx] = sub_delegatept(pts,pt,xrange,yrange,bclose,bnochange)
% SUB_DELEGATEPT This function inserts a new point into the point list
%   If the point is too close to an older point, then an index to the old
%   point is returned

pt = pt(:)';

% Case 0: No points
if isempty(pts),
    pts = pt;
    idx = 1;
    return;
end;

% Case 1: Close to a point
% find close points
diffptx = pts(:,1) - pt(1,1);
diffpty = pts(:,2) - pt(1,2);

% if no change allowed, pick closest point
if bnochange,
    [val,idx] = min(sqrt(diffptx.^2+diffpty.^2));
    return;
end;

idx1 = find(abs(diffptx)<0.03*diff(xrange));
idx2 = find(abs(diffpty)<0.03*diff(yrange));
closepts = intersect(idx1,idx2);

% if there exists a really close point
if ~isempty(closepts)
    idx = closepts(1);
    return;
end;

% Case 2: Not a polygon yet
% If the set of points don't describe a polygon yet. There must be atleast 3
% points to define a triangle
if size(pts,1)<=2,
    pts = [pts;pt];
    idx = size(pts,1);
    return;
end;

% Case 3: Insert point into a polygon
% Determine where to insert the point by evaluating the closest line segment
% to the current point such that a perpendicular dropped from the current
% point to the line segment intersects internally with the line segment

% create a set of vectors for all the line segments of the polygon
linesegs = [pts(2:end,:);pts(1,:)]-pts;
% determine their magnitudes
magsegs = sqrt(sum(linesegs.*linesegs,2));

% create vectors with the current point and each point of the polygon
ptsegs(:,1) = pt(1)-pts(:,1);
ptsegs(:,2) = pt(2)-pts(:,2);

% determine the projections of the point based vectors on the line segments
proj = sum(ptsegs.*linesegs,2)./magsegs; % signed magnitude of projections

% determine the projection vectors
projvecs = repmat(proj,1,2).*(linesegs./repmat(magsegs,1,2));

% determine the point of intersections. useful for debugging
% ptint = pts+projvecs;

% determine the valid intersection points, i.e. those points where
% the intersection is internal. This is based on two constraints. The
% first is that dot-product of the projection vectors and the linesegments
% is positive i.e. in the same direction. The second is that the magnitude
% of the projection is less than the magnitude of the line segment. This 
% provides valid intersection points
ptidx = find(sum(projvecs.*linesegs,2)>0 & proj<magsegs);

% if ptidx is empty, i.e. all projections are outside the line segments
% then pick the closest point
if isempty(ptidx),
    [val,idx] = min(sqrt(diffptx.^2+diffpty.^2));
    return;
end;

% If the number of valid points is greater than one, then pick the closest one.
% This has the shortest perpendicular distance.
if length(ptidx)>1,
    perpsegs = projvecs(ptidx,:)-ptsegs(ptidx,:);
    magperpsegs = sqrt(sum(perpsegs.*perpsegs,2));
    [minval,minidx] = min(magperpsegs);
    ptidx = ptidx(minidx);
end;

% add new point dependent on whether it is the last segment or not
if ptidx == size(pts,1), % last segment
    pts = [pts;pt];
    idx = size(pts,1);
else,                   % any other segment
    pts = [pts(1:ptidx,:);pt;pts((ptidx+1):end,:)];
    idx = ptidx+1;
end;

function  pt = sub_setbounds(pt,xrange,yrange)
% SUB_SETBOUNDS Sets the bounds such that the points cannot go outside the
%   axis

% Restrain points to within the axis
pt(1) = max(min(pt(1),xrange(2)),xrange(1));
pt(2) = max(min(pt(2),yrange(2)),yrange(1));

function bkeep = sub_keepconvex(pts,pt,idx)
if nargin==2,
    pts = [pts;pt];
else,
    pts(idx,:) = pt;
end;
k = unique(convhull(pts(:,1),pts(:,2)))
if (length(k)==length(pts)),
    bkeep = 1;
else,
    bkeep = 0;
end;

function sub_drawpoints(line_hdl,pts,bclose);
% SUB_DRAWPOINTS Draws the points as a closed polygon or as a line
if isempty(pts),
    set(line_hdl,'XData',[],'YData',[]);    
    return;
end;

if bclose,
    pts1 = [pts;pts(1,:)];
    set(line_hdl,'XData',pts1(:,1),'YData',pts1(:,2));    
else,
    set(line_hdl,'XData',pts(:,1),'YData',pts(:,2));    
end

function pts = sub_removeredundantpts(pts,ptidx,xrange,yrange)
%return;
if size(pts,1)<3,
    return;
end;
ptdiff = diff(pts);

slope1 = ptdiff(:,2)./ptdiff(:,1);
diffslope1 = diff(slope1);
slope2 = ptdiff(:,1)./ptdiff(:,2);
diffslope2 = diff(slope2);

idx = find(isnan(diff(abs(slope1))) | ...
    isnan(diff(abs(slope2))) | ...
    abs(diffslope1)<0.2*diff(yrange)/diff(xrange) | ...
    abs(diffslope2)<0.2*diff(xrange)/diff(yrange));
if ~isempty(idx),
    pts = pts(setdiff([1:size(pts,1)],1+idx),:);
end;