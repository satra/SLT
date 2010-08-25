function [A, newVertices,t] = rotateSurf(a,t,vertices)
% a is a 3 x 1 vector of rotation angles (about x,y,z axis)
% t is a 3 x 1 translation vector

%a = deg2rad(a); % convert to radians

a = 2*pi*a/360;

rot1 = [1 0 0; 0 cos(a(1)) -sin(a(1)); 0 sin(a(1)) cos(a(1))];
rot2 = [cos(a(2)) 0 sin(a(2)); 0 1 0; -sin(a(2)) 0 cos(a(2))];
rot3 = [cos(a(3)) -sin(a(3)) 0; sin(a(3)) cos(a(3)) 0; 0 0 1];

A = rot3*rot2*rot1;

newVertices = (rot1 * vertices')';      % rotate about x
newVertices = (rot2 * newVertices')';   % rotate about y
newVertices = (rot3 * newVertices')';   % rotate about z

newVertices = newVertices + repmat(t',length(vertices),1);

