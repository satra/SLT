function [verts1,AS] = st_boundaryVertices(surf,verts,faceids)
% [VERTS1,AS] = ST_BOUNDARYVERTICES(SURF,VERTS,FACEIDS) finds the
% vertices bordering the faces provided in faceids by eliminating
% all the vertices in the center of the region.
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

faces = surf.faces(faceids,:);
angles= surf.angles(faceids,:);
verts1 = ones(size(verts));
AS = ones(size(verts));
for i=1:length(verts),
    AS(i) = sum(angles(find(faces==verts(i))));
    if abs(AS(i)-2*pi)<1e-1,
        verts1(i) = 0;
    end
end;
