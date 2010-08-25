function htrans = setdata(htrans,varargin)
% SETDATA Allows public setting of certain member variables

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/@uitransfer/setdata.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

% check validity of the object
if ~htrans.validui,
    error('Invalid object handle');
end;

htrans = get(htrans.line,'userdata');

switch lower(varargin{1}),
case 'points',
    pts = varargin{2};
    htrans.pts = pts;
    
    xaxischanged = 0;
    yaxischanged = 0;
    if any(pts(:,1)<htrans.xrange(1) | pts(:,1)>htrans.xrange(2))
        htrans.xrange(1) = min(pts(:,1));
        htrans.xrange(2) = max(pts(:,1));
        xaxischanged = 1;
    end;
    if any(pts(:,2)<htrans.yrange(1) | pts(:,2)>htrans.yrange(2))
        htrans.yrange(1) = min(pts(:,2));
        htrans.yrange(2) = max(pts(:,2));
        if abs(htrans.yrange(1)-htrans.yrange(2))<eps,
            htrans.yrange(1) = htrans.yrange(1)-0.1;
            htrans.yrange(2) = htrans.yrange(1)+0.1;
        end;
        yaxischanged = 1;
    end;

    if xaxischanged,
        set(htrans.axs,...
            'XLim',htrans.xrange);
    end;
    if yaxischanged,
        set(htrans.axs,...
            'YLim',htrans.yrange);
    end;
    
    % update the information in object
    set(htrans.line,'userdata',htrans);
    
    % redraw the line
    set(htrans.line,'XData',htrans.pts(:,1),'YData',htrans.pts(:,2));        
case 'xlim',
    old_range = htrans.xrange;
    
    new_range = sort(varargin{2});
    if diff(new_range)==0,
        error('Values for xlim must be increasing');
    end;
    
    htrans.xrange = new_range(:)';

    pts = htrans.pts(:,1);
    %pts = diff(new_range)*(pts-old_range(1))/diff(old_range)+new_range(1);
    %htrans.pts(:,1) = pts;
    if min(pts)<htrans.xrange(1),
        htrans.xrange(1) = min(pts)-0.1;
    end;
    if max(pts)>htrans.xrange(2),
        htrans.xrange(2) = max(pts)+0.1;
    end;
    
    set(htrans.axs,...
        'XLim',htrans.xrange);
    % update the information in object
    set(htrans.line,'userdata',htrans);
    
    % redraw the line
    set(htrans.line,'XData',htrans.pts(:,1),'YData',htrans.pts(:,2));        
case 'ylim',
    old_range = htrans.yrange;
    
    new_range = sort(varargin{2});
    if diff(new_range)==0,
        error('Values for ylim must be increasing');
    end;
    
    htrans.yrange = new_range(:)';

    pts = htrans.pts(:,2);
    %pts = diff(new_range)*(pts-old_range(1))/diff(old_range)+new_range(1);
    %htrans.pts(:,2) = pts;
    
    if min(pts)<htrans.yrange(1),
        htrans.yrange(1) = min(pts)-0.1;
    end;
    if max(pts)>htrans.yrange(2),
        htrans.yrange(2) = max(pts)+0.1;
    end;

    set(htrans.axs,...
        'YLim',htrans.yrange);
    % update the information in object
    set(htrans.line,'userdata',htrans);
    
    % redraw the line
    set(htrans.line,'XData',htrans.pts(:,1),'YData',htrans.pts(:,2));        
case 'value',
    val = varargin{2};
    if val<htrans.yrange(1) | val>htrans.yrange(2),
        error('value not in yrange');
    end;
    
    htrans.pts = [htrans.xrange' [val;val]];
    % update the information in object
    set(htrans.line,'userdata',htrans);
    
    % redraw the line
    set(htrans.line,'XData',htrans.pts(:,1),'YData',htrans.pts(:,2));        
otherwise,
    error('Invalid parameter');
end;