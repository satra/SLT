function pts = removeredundantpts(htrans)
% REMOVEREDUNDANTPTS Removes redundant points from the list
%   Redundancy is based on the following 3 criteria
%   1. The new point is too close to an old point
%   2. Vertical slopes at the edges of the function
%   3. Consecutive segments with the same slope
%   This function eliminates any any points which give rise to
%   any of the above three functions

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/@uitransfer/private/removeredundantpts.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

idx = htrans.idx;
pts = htrans.pts;

% condition 1. Only two points
% disp('condition 1.');
if size(pts,1)==2,
    return;
end;

% Condition 2. The last moved point was too close to another point
%   Eliminate the last moved point
% disp('condition 1.');
if idx == 1,
    idx = 2;
elseif idx == size(pts,1),
    idx = idx-1;
end;
pt = pts(idx,:);
pts1 = pts(setdiff([1:size(pts,1)],idx),:);
% find closest point
diffptx = pts1(:,1) - pt(1,1);
diffpty = pts1(:,2) - pt(1,2);
idx = find(abs(diffptx)<0.03*diff(htrans.xrange));
if length(idx)>1,
    [mdy,idx1] = min(abs(diffpty(idx)));
    idx = idx(idx1);
end;
if abs(diffptx(idx)) < 0.03*diff(htrans.xrange) & abs(diffpty(idx)) <0.03*diff(htrans.yrange),
    pts = pts1;
    return;
end


% Condition 3. Eliminate vertical slopes at the ends
% disp('condition 3.');
ptdiff = diff(pts);
idx = [];
if ptdiff(1,1) <0.03*diff(htrans.xrange),
    idx = 1;
end;
if ptdiff(end,1) <0.03*diff(htrans.xrange),
    idx = [idx,size(pts,1)];
end;
if ~isempty(idx),
    pts = pts(setdiff([1:size(pts,1)],idx),:);
    pts(1,1) = htrans.xrange(1);pts(size(pts,1),1) = htrans.xrange(2);
    return;
end;

% Condition 4. Eliminate consecutive segments with the same slope
% disp('condition 4.');
ptdiff = diff(pts);

slope = ptdiff(:,2)./ptdiff(:,1);
diffslope = diff(slope);

idx = find(isnan(diff(abs(slope))) | abs(diffslope)<0.2*diff(htrans.yrange)/diff(htrans.xrange));
if ~isempty(idx),
    pts = pts(setdiff([1:size(pts,1)],1+idx),:);
end;