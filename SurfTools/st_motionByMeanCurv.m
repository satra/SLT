function [ surf ] = st_motionByMeanCurv( surf, iters, alpha)
% SURF = MOTIONBYMEANCURV(SURF,ITERS,ALPHA) Inflate the surface
% using mean edge vector for ITERS number of iterations going out
% by the amount ALPHA on each iteration. 

% TODO:
%   Currently the mean edge vector is used to propagate the
%   vertex. Still to try, the mean curvature normal operator 
%   Implemented as a mex file (reduces time by 66%);
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

surf.vertices = edgemotionMEX(surf.vertices,uint32(surf.edges-1),iters,alpha);
