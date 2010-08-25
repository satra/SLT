function callback(htrans,cbtype)
% CALLBACK Handles all callbacks for the uicontrol
%   The callback handles button down, drag and button up notifications
%   The button down function can either cause the creation or deletion of
%   points. Left click for creation, right click for deletion. The function
%   takes as input the class instance and the type of callback
%       cbtype is {'btnup','btndown' or 'btnmove'}

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/@uitransfer/callback.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

% check validity of the object
if ~htrans.validui,
    error('Invalid object handle');
end;


switch cbtype,
    % Button Down callback
case 'btndown',
    % Get the current point
    pt = get(htrans.axs,'CurrentPoint');
    pt = pt(1,1:2);
    
    % Insert the point in the appropriate location and return the
    % index of the location
    [htrans.pts,htrans.idx] = delegatept(htrans,pt);
    
    % Set bounds on points such that they remain within the normalized
    % rectangle
    pt = setbounds(htrans,pt) ;
    
    % Get click type
    button = get(htrans.fig,'Selectiontype');
    if strcmp(button,'alt'),    % right click
        % do not delete edge points
        if htrans.idx == 1 | htrans.idx == size(htrans.pts,1),
            return;
        end;
        
        % otherwise deleted the point indexed
        % If the point was a new point it is removed
        % otherwise an old point which was right clicked on is removed
        htrans.pts = [htrans.pts(1:(htrans.idx-1),:);htrans.pts((htrans.idx+1):end,:)];
        set(htrans.line,'userdata',htrans);
        set(htrans.line,'XData',htrans.pts(:,1),'YData',htrans.pts(:,2));    
        return;
    else,
        % Update the location of the indexed point
        htrans.pts(htrans.idx,:) = pt;
        set(htrans.line,'XData',htrans.pts(:,1),'YData',htrans.pts(:,2));    
    end;
    
    % Store the movement functions of the figure
    htrans.strbtnup = get(htrans.fig,'WindowButtonUpFcn');
    htrans.strbtnmv = get(htrans.fig,'WindowButtonMotionFcn');
    
    % Update the object information
    set(htrans.line,'userdata',htrans);
    
    % Create new callbacks for the movement
    set(htrans.fig,'WindowButtonUpFcn',...
        sprintf('callback(get(findobj(''Tag'',''%s''),''userdata''),''btnup'');',htrans.tagname));
    set(htrans.fig,'WindowButtonMotionFcn',...
        sprintf('callback(get(findobj(''Tag'',''%s''),''userdata''),''btnmove'');',htrans.tagname));
case 'btnup',
    % Restore the original callbacks for the figure
    set(htrans.fig,'WindowButtonUpFcn',htrans.strbtnup);
    set(htrans.fig,'WindowButtonMotionFcn',htrans.strbtnmv);
    
    % Remove redundant points from the function
    % See the function 'removeredundantpts' for more details
    htrans.pts = removeredundantpts(htrans);
    
    % update object information
    set(htrans.line,'userdata',htrans);
    
    % update the line
    set(htrans.line,'XData',htrans.pts(:,1),'YData',htrans.pts(:,2));
case 'btnmove',
    % Get the current point in the figure where the mouse is
    % and convert it with respect to the axes
    
    pt = get(htrans.axs,'CurrentPoint');
    pt = pt(1,1:2);
    
    % Set the bounds on the point
    pt = setbounds(htrans,pt);    
    htrans.pts(htrans.idx,:) = pt;
    
    % update the information in object
    set(htrans.line,'userdata',htrans);
    
    % redraw the line
    set(htrans.line,'XData',htrans.pts(:,1),'YData',htrans.pts(:,2));    
otherwise,
    error(['Undefined callback: ' cbtype]);
end;