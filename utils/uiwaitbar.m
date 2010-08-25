function hproc = uiwaitbar(varargin)
% UIWAITBAR A uicontrol for timing processes
%   This function opens a gui that shows the progress of some iterative process.
%   See demowait for an example of the function. 
%
%   Initialization:
%       hproc = uiwaitbar('title'); % creates new figure
%       hproc = uiwaitbar(fig_handle,pos,'title'); % embeds in current figure
%       hproc = uiwaitbar(figh,axis_handle,'title'); % embeds in current figure in axis
%   Inside loop:
%       uiwaitbar(val,hproc,'title','updated_title');
%       val has to be in the range [0 1]
%       hproc is the process handle
%       updated_title is an optional argument if you want to update the title
%       Note: One can use a val of 0 to reset the figure at any point in time
%   Close:
%       delete(hproc); 
%       Depending on the type of initialization, the figure or the axis or only the bar
%       is deleted;
%
%   Examples loop:
%         h = uiwaitbar('Please wait...');
%         for i=1:100,
%             % computation here %
%             uiwaitbar(i/100,h)
%         end
%         delete(h) % or reuse

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/uiwaitbar.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE
persistent prev_val

switch nargin
case 1, %initialization type 1
    % create figure;
    hproc = figure(...
        'units','normalized',...
        'position',[0.3 0.3 0.5 0.1],...
        'DoubleBuffer','on',...
        'Name','UIWaitbar',...
        'IntegerHandle','Off',...
        'Interruptible', 'off', ...
        'Numbertitle','off',...
        'Menubar','none'...
        );
    
    centerfig(hproc);
    
    % set axis position
    axsleft = 0.1;
    axsbot = 0.3;
    axswidth = 0.8;
    axsheight = 0.2;
    
    % call type 2 initialization
    axshdl = uiwaitbar(hproc,[axsleft axsbot axswidth axsheight],varargin{1});
    data = get(axshdl,'userdata');
    
    % update the information in the figure;
    set(hproc,'userdata',data);
    set(hproc,'HandleVisibility','callback');
    prev_val = NaN;
case 3, % initialization type 2
    figh = varargin{1};
    pos = varargin{2};
    
    set(figh,'units','normalized','doublebuffer','on');
    
    if length(pos) == 4,
        % Create the axis
        hproc = axes(...
            'Parent',figh,...
            'position',pos);
    else,
        hproc = pos;
    end
    set(hproc,...
        'units','normalized',...
        'XLim',[0 1],...
        'YLim',[0 1],...
        'Xtick',[],...
        'Ytick',[]);
    
    % store title handle
    data.title_hdl = title(varargin{3});
    
    % Store the time of creation. All calculations of elapsed and estimated
    % time are dependent on the time of creation
    data.first_time= cputime;
    
    % Store handles to the xlabel
    data.x_str = sprintf('S: %s E: ',datestr(now,14));
    data.x_hdl = xlabel([data.x_str time_elapse(cputime-data.first_time)]);
    
    % create the progress bar rectangle
    data.rect_hdl = rectangle('position',[0 0 1e-5 1],'Facecolor','r');
    
    % store data in rectangle if axis was provided
    if length(pos)==1,
        hproc = [data.rect_hdl;data.title_hdl;data.x_hdl];
    end;
    
    % update the information in the axis;
    set(hproc(1),'userdata',data);
case 2,    % runtime operation
    % This case deals with runtime operation or resetting of the progress
    % bar
    
    % Convert the inputs
    val = varargin{1};      % fractional completion value
    hproc = varargin{2};    % handle to the progress bar
    set(hproc,'HandleVisibility','on');
    hproc = hproc(1);
    
    % get stored data
    data = get(hproc,'userdata');
    
    if val == 0,    % reset
        % reinitialize time
        data.first_time = cputime;
        data.x_str = sprintf('S: %s E: ',datestr(now,14));
        
        set(data.x_hdl,'string',[data.x_str time_elapse(cputime-data.first_time) ' Est: ' time_elapse(0)]);
        set(data.rect_hdl,'position',[0 0 1e-5 1]);
        
        % update data
        set(hproc,'userdata',data);
        prev_val = NaN;
    else,           % update progress bar
            if (val-prev_val)> 0.01 | isnan(prev_val)
                set(data.x_hdl,'string',[data.x_str time_elapse(cputime-data.first_time) ' Est: ' time_elapse((cputime-data.first_time)/val)]);
                set(data.rect_hdl,'position',[0 0 val 1]);
                prev_val = val;
            end
    end;
    
    
    % refresh
    drawnow;
    set(hproc,'HandleVisibility','callback');
case 4,
    uiwaitbar(varargin{1:2});
    
    if strcmp(lower(varargin{3}),'title'),
        hproc = varargin{2};    % handle to the progress bar
        hproc = hproc(1);
        
        % get stored data
        data = get(hproc,'userdata');
        set(data.title_hdl,'string',varargin{4});
    end;
    
otherwise
    error('Wrong number of input arguments')
end

function str = time_elapse(diff_t)
% TIME_ELAPSE Subfunction that converts a time difference to a string format
%   of the type: 
%       Days:Hours:Months:Seconds.100s_of_milliseconds

days   = fix(round(diff_t)/(24*3600));
diff_t  = (diff_t-days*(24*3600));
hours   = fix(round(diff_t)/3600);
diff_t  = (diff_t-hours*3600);
minutes = fix(round(diff_t)/60);
diff_t  = (diff_t-minutes*60);
seconds = fix(diff_t);
ms  = fix((diff_t-fix(diff_t))*10);

str = sprintf('%01d:%02d:%02d:%02d.%1d',days,hours,minutes,seconds,ms);
