function [X,Y]=pr_stereographic(Long,Lat,R,Par);
%--------------------------------------------------------
% pr_stereographic function   Project coordinates to the
%                     Stereographic projection
%                     for set of longitude and latitude.
%                     This is a map projection in which great circles
%                     and Loxodromes are logarithmic spirals.
% Input  : - vector of Longitude, in radians.
%          - vector of Latitude, in radians.
%          - Scale radius, default is 1.
%          - [Central_Longitude, Standard_Parallel] default [0 0]
% Output : - vector of X position
%          - vector of Y position 
%    By : Eran O. Ofek             August 1999     
%--------------------------------------------------------
if (nargin==4),
   % no default
elseif (nargin==3),
   % no default
   Par = [0 0];
elseif (nargin==2),
   R = 1;
   Par = [0 0];
else
   error('Illigal number of argument');
end

Long0 = Par(1);
Lat1  = Par(2);

K     = 2./(1+sin(Lat1).*sin(Lat)+cos(Lat1).*cos(Lat).*cos(Long-Long0));

X     = K.*R.*cos(Lat).*sin(Long - Long0);
Y     = K.*R.*(cos(Lat1).*sin(Lat) - sin(Lat1).*cos(Lat).*cos(Long - Long0));

