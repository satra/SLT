function haxes = mat_cplot(dataslice,haxes)
% Draws a contour plot.

load('mat_chanpos.mat','sens');



% To project the 3D coordinates into 2D space
%sx = sensorLocs(:,1);
%sy = sensorLocs(:,2);
%sz = sensorLocs(:,3);
%[th,ph,r] = cart2sph(sx,sy,sz);
%[x,y] = pol2cart(th+pi/2,r.*(pi/2-ph));
%sens.x = x(1:157);
%sens.y = y(1:157);
%save -append mat_chanpos.mat sens;

% Define the grid 
n = 64; % Number of columns in grid 
m = 64; % Number of rows in grid 
x1 = linspace(min(sens.x),max(sens.x),n); % Define X-grid 
y1 = linspace(min(sens.y),max(sens.y),m); % Define Y-grid 
[Xi,Yi] = meshgrid(x1,y1); % Produce the new grid 

if (nargin<2),
   figure;
   clf;
   haxes = axes;
else,
   axes(haxes);
end;

cla;
hold on;
Zi = griddata(sens.x,sens.y,dataslice,Xi,Yi,'linear'); %linear/invdist
[c,h] = contourf(x1,y1,Zi,20);
colorbar;

plot(sens.x,sens.y,'ko');
plot(sens.x,sens.y,'k*');

i=[1:length(sens.x)];
text(sens.x+10,sens.y,num2str((i-1)'));
rectangle('Curvature',[1 1],'Position',[-300 -280 600 500],'Linewidth',2);
line([-40 0 40],[220 270 220],'Color','k','Linewidth',2);
