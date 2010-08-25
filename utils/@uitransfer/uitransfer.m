function htrans = uitransfer(varargin)
% UITRANSFER A uicontrol for drawing transfer functions
%   The uicontrol allows one to draw functions of arbitrary shape. One can
%   either create a uicontrol with default settings (creates its own figure 
%   window) or it can provide a position in a given figure for the the control
%   to establish its presence.
%       Examples:
%       1. 0 input arguments
%       htrans = uitransfer; % default setting
%       2. 4 input arguments
%       htrans = uitransfer(figure_handle,[left bottom width height],...
%                           [xmin xmax],[ymin ymax]);
%   For this uicontrol to function properly, the units must be normalized in terms
%   of the figure. This may be altered in future versions, but for current purposes
%   the figure has to be created with the parameter 'units'->'normalized'.
%   The uicontrol will change the units parameter of the figure when first called, if
%   the units are not normalized. It will also set the doublebuffer property of
%   th figure to 'on'.

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/@uitransfer/uitransfer.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

switch nargin
case 0,
    % create figure;
    htrans.fig = figure(...
        'units','normalized',...
        'position',[0.3 0.3 0.5 0.3],...
        'DoubleBuffer','on',...
        'Name','UITransfer',...
        'Numbertitle','off',...
        'Menubar','none'...
        );
    % The control created the figure;
    htrans.controlfig = 1;
    centerfig(htrans.fig);
    
    % set axis position
    htrans.axsleft = 0.1;
    htrans.axsbot = 0.1;
    htrans.axswidth = 0.8;
    htrans.axsheight = 0.8;
    
    % set ranges
    htrans.xrange = [0 1];
    htrans.yrange = [0 1];
    
    % call the subfunction;
    htrans = create_axis(htrans);
case 1    
    % if single argument of class operator, return it
    if (isa(varargin{1},'uitransfer'))
        htrans = varargin{1};
    else
        error('Wrong argument type')
    end
case 4,
    % store figure handle
    htrans.fig = varargin{1};
    set(htrans.fig,'units','normalized','Doublebuffer','on');
    % The figure handle was provided
    htrans.controlfig = 0;
    
    % second paramter is either an axis handle or the position
    % of the axis. check and store
    pos = varargin{2};
    if length(pos) == 1,
        axh = pos;
        set(axh,'units','normalized');
        pos = get(axh,'Position');
    end;
    
    % store the axis position in appropriate fields
    htrans.axsleft = pos(1);
    htrans.axsbot = pos(2);
    htrans.axswidth = pos(3);
    htrans.axsheight = pos(4);
    
    % store the range of the axes
    htrans.xrange = sort(varargin{3});
    htrans.yrange = sort(varargin{4});
    
    % call the subfunction;
    if exist('axh','var'),  % axis handle was provided
        htrans = create_axis(htrans,axh);
    else,                   % axis handle not provided
        htrans = create_axis(htrans);
    end;        
otherwise
    error('Wrong number of input arguments')
end

function htrans = create_axis(htrans,axh)
% CREATE_AXIS Sub function that does most of the creation work
%   This code was separated to reduce reduplication of code for the various
%   cases

% Store the figure's callback functions
htrans.strbtnup = get(htrans.fig,'WindowButtonUpFcn');
htrans.strbtnmv = get(htrans.fig,'WindowButtonMotionFcn');

if nargin<2, % create axis
    htrans.axs = axes(...
        'Parent',htrans.fig,...
        'position',[htrans.axsleft htrans.axsbot htrans.axswidth htrans.axsheight],...
        'XLim',htrans.xrange,...
        'YLim',htrans.yrange);
    % Axes was created by the control
    htrans.controlaxs = 1;
else, % set axis handle
    htrans.axs = axh;
    % Axes was provided by application
    htrans.controlaxs = 0;
    htrans.xrange = get(htrans.axs,'Xlim');
    htrans.yrange = get(htrans.axs,'Ylim');
    htrans.xrange = htrans.xrange(:)';
    htrans.yrange = htrans.yrange(:)';
end;

% create line
htrans.pts = [htrans.xrange(1) mean(htrans.yrange);htrans.xrange(2) mean(htrans.yrange)];

% All the callbacks require the handle of the uicontrol object and this 
% is stored in the line object
htrans.tagname = sprintf('Lineobj%f.tag%f',rand,rand);
htrans.line = line(htrans.pts(:,1),htrans.pts(:,2),...
    'Parent',htrans.axs,...
    'Marker','s',...
    'Hittest','off',...
    'Tag',htrans.tagname);

% This field indicates which point is being moved during a move
htrans.idx = 1;

% A valid uicontrol .. once deleted no more
htrans.validui = 1;

% create the class object
htrans = class(htrans,'uitransfer');  

% update the data in the line object with the class object
set(htrans.line,'userdata',htrans);

% set the button down function of the object
set(htrans.axs,'Buttondownfcn',...
    sprintf('callback(get(findobj(''Tag'',''%s''),''userdata''),''btndown'');',htrans.tagname));    
