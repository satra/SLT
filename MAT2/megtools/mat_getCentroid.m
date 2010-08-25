function [c] = mat_getCentroid(tSurf)

% Author: Jay Bohland
% Date: 08/10/03
%
% This function returns the centroid (center of mass) of a surface by
% weighting vertices' contributions by the size of the faces they comprise
%
% Input: tSurf - a structure containing fields:
%          .vertices - N x 3 matrix of vertex locations
%          .faces    - M x 3 matrix of triangular faces (the indices of the
%                                      vertices that comprise them)
% Output: 1 x 3 vector containing the centroid of the surface

totalMass = [0 0 0];
totalArea = [0 0 0];

% Do this per face... I think I can clean this up
for i=1:length(tSurf.faces),
    A = norm(kron((tSurf.vertices(tSurf.faces(i,2),:)-tSurf.vertices(tSurf.faces(i,1),:)), ...
                  (tSurf.vertices(tSurf.faces(i,3),:)-tSurf.vertices(tSurf.faces(i,1),:))));
    R = mean(tSurf.vertices(tSurf.faces(i,:),:));
    
    totalMass = totalMass + A.*R;
    totalArea = totalArea + A;
end;

c = totalMass ./ totalArea;