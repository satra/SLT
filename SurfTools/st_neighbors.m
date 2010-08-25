function nb = st_neighbors(surf,v)
% NB = ST_NEIGHBORS(SURF,V) returns the neighbors of the vertex
% indexed by V.
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

nb = surf.edges([surf.Nidx(v,1):surf.Nidx(v,2)]',2);
