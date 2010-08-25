function [ value ] = st_smoothVertexValue(surf,value,varargin)
%SMOOTHVERTEXVALUE Smooths using mean of immediate neighborhood values
%   Smooth the value at each vertex by taking the mean of the neighboring and
%   current vertex value;
%   Implemented as a mex file
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p
% Satra $

% $NoKeywords: $

[value] = smoothMEX(uint32(surf.edges-1),value);
