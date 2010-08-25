function [chans,coil_coord,normal_dir] = mat_getChans(chan_type,badchans)

% Load channel information and decide which channels to use
load mat_chanpos;
coil_coord = sensorLocs(:,1:3)/1e3; % convert from mm to m

chans = 1:93;
midlinechans = setdiff(chans,union(leftIndices,rightIndices));
lchans = union(leftIndices,midlinechans);
rchans = union(rightIndices,midlinechans);

switch(chan_type),
case 'right',
    chans = setdiff(rchans,badchans);
case 'left',
    chans = setdiff(lchans,badchans);
case 'all',
    chans = setdiff([1:93],badchans);
otherwise,
end;

chans = chans(:);

coil_coord = coil_coord(chans,:);
normal_dir = sensorOris(chans,:);
