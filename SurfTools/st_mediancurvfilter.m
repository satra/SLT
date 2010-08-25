function [mc1] = st_mediancurvfilter(surf,mc,iter);
% MC1 = ST_MEDIANCURVFILTER(SURF) calculates the median value of
% the mean curvature for each vertex. 
%
% MC1 = ST_MEDIANCURVFILTER(SURF,MC) calculates the median value of
% the values provided in the vector MC.
%
% MC1 = ST_MEDIANCURVFILTER(SURF,MC,ITER) performs the calculation
% for ITER number of iterations.
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

[mc1] = curvfilterMEX(uint32(surf.edges-1),mc,iter);
