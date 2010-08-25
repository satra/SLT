function EN = st_eulerNumber(surf)
% EN = ST_EULERNUMBER(SURF) computes the Euler number of the surface
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

EN = size(surf.vertices,1)+size(surf.faces,1) - surf.nedges;
