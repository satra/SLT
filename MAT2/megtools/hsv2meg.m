function [hsv] = hsv2meg(hsv,markerFile,useMarkers)

% This function reads in marker file locations from a .mat file and calculates a transformation
% from head shape space to sensor space.  See file formats in readme.txt. It then returns the
% head shape volume in sensor (MEG) coordinates.  useMarkers is an array
% of the three marker indices you wish to use.

global dirTemplate;  % defined elsewhere (try alignCoordinateFrames.m)

load(fullfile(dirTemplate.input,markerFile),'dMarkers','sMarkers');
[A, b] = mat_rotsolve(dMarkers(useMarkers,:)',sMarkers(useMarkers,:)')  % Find best fit transform

hsv.vertices = (A * (hsv.vertices(:,[1 2 3]))' + repmat(b, 1, length(hsv.vertices')))'; 


