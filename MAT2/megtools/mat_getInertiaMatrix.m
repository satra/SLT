function [M] = mat_getInertiaMatrix(tSurf)

% Author: Jay Bohland
% Date: 08/10/03
% This function returns the 3-D inertia matrix for the set of vertices
% belonging to the surface tSurf
%
% Input: tSurf - a structure containing fields:
%          .vertices - N x 3 matrix of vertex locations
%          .faces    - M x 3 matrix of triangular faces (the indices of the
%                                      vertices that comprise them)
% Output: 3 x 3 inertia matrix (see code for details)

pts = tSurf.vertices;

% Second order moments
Mxx = sum(pts(:,2).^2 + pts(:,3).^2);
Myy = sum(pts(:,1).^2 + pts(:,3).^2);
Mzz = sum(pts(:,1).^2 + pts(:,2).^2);

Mxy = sum(pts(:,1) .* pts(:,2));
Mxz = sum(pts(:,1) .* pts(:,3));
Myz = sum(pts(:,2) .* pts(:,3));

M = [Mxx Mxy Mxz; ...
     Mxy Myy Myz; ...
     Mxz Myz Mzz];
 
 


