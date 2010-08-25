function [normals,th,FVA] = st_calcNAA(v,f)
% [NORMALS,TH,FVA] = ST_CALCNAA(V,F)  Utility function that
% calculates normals, angles and areas for a surface. The inputs
% required are the surface vertices and the corresponding
% faces. The function calculates the face normals, the 3 angles for
% each face and the approximate Voronoi area of the triangle
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% compute edge vectors for each face and their euclidean norm
v31 = v(f(:,3),:)-v(f(:,1),:);v31n = sqrt(sum(v31.*v31,2));
v21 = v(f(:,2),:)-v(f(:,1),:);v21n = sqrt(sum(v21.*v21,2));
v32 = v(f(:,3),:)-v(f(:,2),:);v32n = sqrt(sum(v32.*v32,2));

% computer normals
normals = cross(v21,v31,2);
normals = normals./repmat((sqrt(sum(normals.*normals,2))),1,3);

% angles using dot product definition
th = acos([...
        sum(v31.*v21,2)./(v31n.*v21n),...
        sum((-v21).*v32,2)./(v21n.*v32n),...
        sum((-v32).*(-v31),2)./(v32n.*v31n)]);

% lengths
d = [v32n v31n v21n];
sp = sum(d,2)/2;

% planar areas of each face
A = sqrt(sp.*(sp-d(:,1)).*(sp-d(:,2)).*(sp-d(:,3)));

clear v31 v21 v32 v21n v31n v32n sp;

% Voronoi areas of each vertex of each face
VA = 1/8*[...
        (d(:,2).^2).*cot(th(:,2))+(d(:,3).^2).*cot(th(:,3)),...
        (d(:,1).^2).*cot(th(:,1))+(d(:,3).^2).*cot(th(:,3)),...
        (d(:,1).^2).*cot(th(:,1))+(d(:,2).^2).*cot(th(:,2))];

% Area allocation based on obtuse/non-obtuse triangle in neighborhood
% See Meyer et al, for details
% Essentially,
% if non-obtuse,
%   area = VA,
% else
%   if vertex is obtuse,
%       A/2,
%   else,
%       A/4;
%

obtuse     = sum(th>(pi/2),2)>0;
FVA = ((th>pi/2)/2+obtuse(:,ones(1,3)).*(th<=pi/2)/4).*A(:,ones(1,3))+(obtuse(:,ones(1,3))==0).*VA;
if any(sum(((th>pi/2)+obtuse(:,ones(1,3)).*(th<=pi/2))+(obtuse(:,ones(1,3))==0),2)~=3),
    error('incorrect area calculation');
end;
