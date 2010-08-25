function [VN,FN] = st_computeNormals(surf)
% [VN,FN] = ST_COMPUTENORMALS(SURF) Computes vertex and face
% normals of the surface 
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

v = surf.vertices;
f = surf.faces;

v31 = v(f(:,3),:)-v(f(:,1),:);v31n = sqrt(sum(v31.*v31,2));
v21 = v(f(:,2),:)-v(f(:,1),:);v21n = sqrt(sum(v21.*v21,2));

% computer normals
normals = cross(v21,v31,2);
FN = normals./repmat((sqrt(sum(normals.*normals,2))),1,3);

surf.normals = FN;

[MC,GC,K1,K2,MN,VN] = st_curvature( surf );
