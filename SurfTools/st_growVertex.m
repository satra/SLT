function verts = st_growVertex(surf,vertid,mc)
% VERTS = ST_GROWVERTEX(SURF,VERTID,MC) takes a surface with
% boolean vertex values and extracts the largest connected
% component having the same value is VERTID.
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

vertlist = 1:length(mc);

newverts = [vertid];
verts = [vertid];
while length(newverts),
    oldverts = verts;
    for vert = newverts,
        nb = neighbors(surf,vert);
        nb = nb(find(mc(nb)==1));
        nb = nb(:)';
        verts = unique(union(verts,nb));
    end;
    newverts = setdiff(verts,oldverts);
end;
