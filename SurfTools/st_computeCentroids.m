function [centroids,facenormals] = st_computeCentroids(surfstruct)
% [CENTROIDS,FACENORMALS] = ST_COMPUTECENTROIDS(SURFSTRUCT)
% computes the centroids and facenormals of each face of the
% surface. 
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

v = surfstruct.vertices;
f = surfstruct.faces';
if nargout>1,
    n = st_computeNormals(surfstruct);
end;
clear surfstruct;

centroids = squeeze(mean(reshape(v(f(:),:)',3,3,length(f)),2))';
if nargout>1,
    facenormals = squeeze(mean(reshape(n(f(:),:)',3,3,length(f)),2))';
    facenormals = normvectors(facenormals);
end;
