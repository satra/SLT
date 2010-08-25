function [volume,numLabels] = getLargestLabel(volume)
% GETLARGESTLABEL This function takes a binary volume and determines the largest 
%   connected component in the volume

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/preprocess.1/getLargestLabel.m 2     10/08/02 2:37p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

[volume,numLabels] = bwlabeln(uint8(volume));
if numLabels>1,
    volume = uint16(volume);    % assume there are less than max_uint16 labels
    
    % this seems the fastest way to sort the labels
    h = hist(double(volume(find(volume(:)))),numLabels);
    [maxval,ind] = max(h);
    volume = uint8(volume == ind);
else
    volume = uint8(volume>0);
end;