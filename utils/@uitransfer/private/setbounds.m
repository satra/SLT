function pt = setbounds(htrans,pt)
% SETBOUNDS Ensures that the line remains a function within the axis

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/@uitransfer/private/setbounds.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

pts = htrans.pts;
idx = htrans.idx;

% Restrain points to within the axis
pt(1) = max(min(pt(1),htrans.xrange(2)),htrans.xrange(1));
pt(2) = max(min(pt(2),htrans.yrange(2)),htrans.yrange(1));

% Don't allow edge points to move
if idx == 1,
    pt(1,1) = htrans.xrange(1);
    return;
end;
if idx == size(pts,1),
    pt(1,1) = htrans.xrange(2);
    return;
end;

% Keep points within the boundaries set by its neighbours
if pts(idx-1,1)>pt(1,1),
    pt(1,1) = pts(idx-1,1);
    return;
end
if pts(idx+1,1)<pt(1,1),
    pt(1,1) = pts(idx+1,1);
    return;
end