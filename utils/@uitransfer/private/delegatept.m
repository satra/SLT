function [pts,idx] = delegatept(htrans,pt)
% DELEGATEPT Inserts the point at an appropriate location
%   This function is responsible for inserting a new point into the
%   structure or returns an index to an old point.

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/@uitransfer/private/delegatept.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE
pts = htrans.pts;

idx = [];   % Index to closest point

% find closest point
diffptx = pts(:,1) - pt(1,1);
diffpty = pts(:,2) - pt(1,2);
idx = find(abs(diffptx)<0.03*diff(htrans.xrange));
if length(idx)>1,
    [mdy,idx1] = min(abs(diffpty(idx)));
    idx = idx(idx1);
end;
% if the closest point is very close, return index to 
% the old point
if abs(diffptx(idx)) < 0.03*diff(htrans.xrange) & abs(diffpty(idx)) <0.03*diff(htrans.yrange),
    return;
end

% Determine the closest point
if isempty(idx),
    [mdx,idx] = min(abs(diffptx));
    idx = find(abs(diffptx)<=mdx);
    if length(idx)>1,
        if diffptx(idx(1))>0,
            idx = idx(1);
        else,
            idx = idx(2);
        end;
    end;
end;

% Insert the point at the appropriate location
if diffptx(idx)<0, % to the left
    pts = [pts(1:idx,:);pt;pts((idx+1):end,:)];
    idx = idx+1;
else,   % to the right
    pts = [pts(1:(idx-1),:);pt;pts(idx:end,:)];    
end;
