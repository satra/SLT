function [f,tri] = st_extractFaces(surf,vertices2extract,type)
% [F,TRI] = ST_EXTRACTFACES(SURF,VERTICES2EXTRACT,TYPE) extracts
% the faces consisting of vertices listed in VERTICES2EXTRACT with
% patterns defined by TYPE. TYPE := 1,2,3 where 1 implies that the
% face contains at least 1 of th vertices, 2 implies faces contains
% two of the listed vertices and 3 implies the face contains all
% the vertices. TRI contains the index of the faces extracted from
% the original face list.
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

v = surf.vertices;
f = surf.faces;
nbdarray = zeros(length(surf.vertices), 1);

%%% Extract out "vertices2extract" from v, to form subv
subv = v(vertices2extract,:); 
    
%%% Find the triangles that have all 3 vertices in "vertices2extract"
nbdarray(vertices2extract) = 1; %%% e.g. [1 0 1 1 0] 
tmp = nbdarray(f); %%% e.g. [1 1 1; 1 0 1; 1 1 1; 1 1 1]
tmp = sum(tmp,2);     %%% e.g. [3; 2; 3; 3]
tri = find(tmp >= type); %%% e.g. = [1 3 4]
f = f(tri,:);
