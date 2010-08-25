function DEMO_sinHillCurvature(NNN)
% See how well curvatureD measures curvature on sinusoidal hills.
%
% DEMO_sinHillCurvature(NNN), where NNN^2 = number of vertices
%
% This surface is parametrized by
% x = u
% y = v
% z = 0.25*sin(2*pi*u).*sin(2*pi*v)
%
% Figure(1); displays estimated minus true gauss curvature on mesh
% Figure(2); displays estimated minus true  mean curvature on mesh
% Figure(3); plot estimated vs true gauss curvature
% Figure(4); plot estimated vs true  mean curvature

[x, y] = meshgrid(linspace(0, 1, NNN));

x = x(:);
y = y(:);
z = (1/4)*sin(2*pi*x).*sin(2*pi*y);

ss.vertices = [x y z];
ss.faces = delaunayQ(x, y);
ss = preprocessQ(ss);
[mcE, gcE] = curvatureD(ss);

vertNorms = computeNormals(ss);
vertNorms = sum(vertNorms);
if vertNorms(3) > 0
  mcE = -mcE;
end

V = size(z,1);
gc = repmat(NaN, V, 1);
mc = repmat(NaN, V, 1);
for i = 1:V

  u = x(i);
  v = y(i);
  
  Xu = [1;
	0;
	(pi/2)*cos(2*pi*u).*sin(2*pi*v)];
  
  Xv = [0;
	1;
	(pi/2)*sin(2*pi*u).*cos(2*pi*v)];
  
  Xuu = [0;
	 0;
	 -(pi^2)*sin(2*pi*u).*sin(2*pi*v)];
  
  Xvv = [0;
	 0;
	 -(pi^2)*sin(2*pi*u).*sin(2*pi*v)];

  Xuv = [0;
	 0;
	 +(pi^2)*cos(2*pi*u).*cos(2*pi*v)];
  
  N = cross(Xu,Xv);
  N = N/norm(N);
  
  E = dot(Xu,Xu);
  F = dot(Xu,Xv);
  G = dot(Xv,Xv);
  
  e = dot(N,Xuu);
  f = dot(N,Xuv);
  g = dot(N,Xvv);
  
  FirstFF = [E F; F G];
  SecondFF = [e f; f g];
  
  A = -SecondFF*inv(FirstFF);
  
  mc(i) = trace(A)/2;
  gc(i) = det(A);
  
end

figure(1); clf
showVertexValue(ss, gcE-gc);
title('estimated minus true gauss curvature on mesh');

figure(2); clf; 
showVertexValue(ss, mcE-mc);
title('estimated minus true mean curvature on mesh');

figure(3); clf;
plot(gc, gcE, '.'); hold on; 
plot([min(gc) max(gc)], [min(gc) max(gc)], 'r');
axis equal
title('estimated vs true gauss curvature');

figure(4); clf;
plot(mc, mcE, '.'); hold on; 
plot([min(mc) max(mc)], [min(mc) max(mc)], 'r');
axis equal
title('estimated vs true mean curvature');

