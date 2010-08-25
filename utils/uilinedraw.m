function varargout = uilinedraw(varargin)
% UILINEDRAW Drawing and editing of a line
%   This function allows one to draw and edit polygons on any axis. Assumes the axis
%   is set to axis image. Only one instance of this should be used at a given time.
%   The usage is as follows:
%   - Left click adds a point or selects an already existing point.
%   - Left click and drag moves the added or selected point
%   - right clicking on a point removes the point
%   - backspace/delete also removes the last point
%   - enter/return finishes editing

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/uilinedraw.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

switch(nargin),
case 0,
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
    d.pts = [];
    d.bclose = 1;
    
    % to take care of matlab indexing
    d.line_hdl = line(...
        'Xdata',[],...
        'Ydata',[]);
    
    % set the properties of the line
    d.linetag = sprintf('Linetag%f.%f',rand,rand);
    set(d.line_hdl,...
        'tag',d.linetag,...
        'Parent',d.dummyaxs,...
        'marker','.',...
        'color','r',...
        'markeredgecolor','r',...
        'Hittest','off');
    
    set(d.line_hdl,'userdata',d);
    sub_drawpoints(d.line_hdl,d.pts,d.bclose);
    
    % Set the required callbacks
    set(d.dummyaxs,'Buttondownfcn',sprintf('uilinedraw(''btndown'',''%s'');',d.linetag));
    set(d.fig,'WindowButtonUpFcn','');
    set(d.fig,'WindowButtonMotionFcn','');
    set(d.fig,'KeyPressFcn',sprintf('uilinedraw(''keypress'',''%s'');',d.linetag));
    set(d.fig,'Pointer', 'crosshair');
    
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
otherwise,
    if ~ischar(varargin{1}),
        error('unknown argument');
    end;
    switch(lower(varargin{1})),
    case 'btndown',
        % Evaluates when a button is pressed in the invisible axes
        d = get(findobj('tag',varargin{2}),'userdata');
        
        % Get the current point
        pt = get(d.axs,'CurrentPoint');
        pt = pt(1,1:2);
        
        % Set bounds on points such that they remain within the normalized
        % rectangle
        pt = sub_setbounds(pt,d.xrange,d.yrange) ;
        
        % Insert the point in the appropriate location and return the
        % index of the location
        d.pts = [d.pts;pt];
        
        % Get click type
        button = get(d.fig,'Selectiontype');
        if strcmp(button,'alt'),    % right click removes the point
            d.pts = d.pts(1:(end-1),:);
        elseif strcmp(button,'extend'),
            set(d.dummyaxs, 'UserData', 'Completed');
            return;
        else
            set(d.fig,'WindowButtonMotionFcn',sprintf('uilinedraw(''move'',''%s'');',d.linetag));
        end;
        
        sub_drawpoints(d.line_hdl,d.pts,d.bclose);
        
        % set the button up function
        set(d.fig,'WindowButtonUpFcn',sprintf('uilinedraw(''btnup'',''%s'');',d.linetag));
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
        
        % update the value of the point
        if isempty(d.pts),
            d.pts = [d.pts;pt];
        else,
            last_pt = d.pts(end,:);
            if any(abs(last_pt-pt)> [0.03*diff(d.xrange) 0.03*diff(d.yrange)]),
            d.pts = [d.pts;pt];
            end
        end;
        
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
        %d.pts = sub_removeredundantpts(d.pts,d.xrange,d.yrange);
        
        % update the line
        sub_drawpoints(d.line_hdl,d.pts,d.bclose);
        set(d.line_hdl,'userdata',d);
    case 'keypress',
        d = get(findobj('tag',varargin{2}),'userdata');
        key = get(d.fig, 'CurrentCharacter');
        switch key
        case {char(8), char(127)}  % delete and backspace keys
            if ~isempty(d.pts),
                d.pts = d.pts(1:(end-1),:);
            end;
            sub_drawpoints(d.line_hdl,d.pts,d.bclose);
            set(d.line_hdl,'userdata',d);
        case {char(13), char(3)}   % enter and return keys
            % return control to line after waitfor
            set(d.dummyaxs, 'UserData', 'Completed');
        end
    case 'bclose',
        d = get(findobj('tag',varargin{3}),'userdata');
        d.bclose = varargin{2};
        set(d.line_hdl,'userdata',d);        
    otherwise,
        error('Unknown argument');
    end
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          SUBFUNCTIONS                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  pt = sub_setbounds(pt,xrange,yrange)
% SUB_SETBOUNDS Sets the bounds such that the points cannot go outside the
%   axis

% Restrain points to within the axis
pt(1) = max(min(pt(1),xrange(2)),xrange(1));
pt(2) = max(min(pt(2),yrange(2)),yrange(1));

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

function pts = sub_removeredundantpts(pts,xrange,yrange)
if size(pts,1)<3,
    return;
end;
ptdiff = diff(pts);

s = warning;
warning off;

slope1 = ptdiff(:,2)./ptdiff(:,1);
diffslope1 = diff(slope1);
slope2 = ptdiff(:,1)./ptdiff(:,2);
diffslope2 = diff(slope2);

warning(s);


idx = find(isnan(diff(abs(slope1))) | ...
    isnan(diff(abs(slope2))) | ...
    abs(diffslope1)<0.1*diff(yrange)/diff(xrange) | ...
    abs(diffslope2)<0.1*diff(xrange)/diff(yrange));

if ~isempty(idx),
    pts = pts(setdiff([1:size(pts,1)],1+idx),:);
end;