function [xi,yi,ii,ri] = sap_polyintersect(varargin)
%POLYINTERSECT  Polygon Intersection.
%
%   [XI,YI] = POLYINTERSECT(X1,Y1,X2,Y2) 

% set input variables
if nargin==4 | nargin==5
	x1 = varargin{1}(:);  y1 = varargin{2}(:);
	x2 = varargin{3}(:);  y2 = varargin{4}(:);
else
	error('Incorrect number of arguments')
end

% check x and y vectors
msg = sap_incheck(x1,y1); if ~isempty(msg); error(msg); end
msg = sap_incheck(x2,y2); if ~isempty(msg); error(msg); end

% determine if both are polygons
if (x1(1)==x1(end) & y1(1)==y1(end)) & (x2(1)==x2(end) & y2(1)==y2(end))
	datatype = 'polygon';
else
	datatype = 'line';
end

% compute all intersection points
[xi,yi,ii] = getintpts(x1,y1,x2,y2);
ri = [];
if isempty([xi yi ii]),  return;  end

function [xi,yi,ii] = getintpts(x1,y1,x2,y2)
%INTPTSALL  Unfiltered line or polygon intersection points.
%   [XI,YI,II] = INTPTSALL(X1,Y1,X2,Y2) returns the unfiltered intersection 
%   points of two sets of lines or polygons, along with a two-column index
%   of line segment numbers corresponding to the intersection points.
%   Note: intersection points are ordered from lowest to hightest line 
%   segment numbers.

%  Written by:  A. Kim


err = eps*1e5;

% form line segment matrices
xs1 = [x1 [x1(2:end); x1(1)]];
ys1 = [y1 [y1(2:end); y1(1)]];
xs2 = [x2 [x2(2:end); x2(1)]];
ys2 = [y2 [y2(2:end); y2(1)]];

% remove last segment (for self-enclosed polygons, this is a non-segment;
% for lines, there are n-1 line segments)
xs1 = xs1(1:end-1,:);  ys1 = ys1(1:end-1,:);
xs2 = xs2(1:end-1,:);  ys2 = ys2(1:end-1,:);

% tile matrices for vectorized intersection calculations
N1 = length(xs1(:,1));  N2 = length(xs2(:,1));
X1 = reshape(repmat(xs1,1,N2)',2,N1*N2)';
Y1 = reshape(repmat(ys1,1,N2)',2,N1*N2)';
X2 = repmat(xs2,N1,1);
Y2 = repmat(ys2,N1,1);

% compute slopes
w = warning;
warning off
m1 = (Y1(:,2) - Y1(:,1)) ./ (X1(:,2) - X1(:,1));
m2 = (Y2(:,2) - Y2(:,1)) ./ (X2(:,2) - X2(:,1));
% m1(find(m1==-inf)) = inf;  m2(find(m2==-inf)) = inf;
m1(find(abs(m1)>1/err)) = inf;  m2(find(abs(m2)>1/err)) = inf;
warning(w)

% compute y-intercepts (note: imaginary values for vertical lines)
b1 = zeros(size(m1));  b2 = zeros(size(m2));
i1 = find(m1==inf);  if ~isempty(i1),  b1(i1) = X1(i1)*i;  end
i2 = find(m2==inf);  if ~isempty(i2),  b2(i2) = X2(i2)*i;  end
i1 = find(m1~=inf);  if ~isempty(i1),  b1(i1) = Y1(i1) - m1(i1).*X1(i1);  end
i2 = find(m2~=inf);  if ~isempty(i2),  b2(i2) = Y2(i2) - m2(i2).*X2(i2);  end

% zero intersection coordinate arrays
sz = size(X1(:,1));  x0 = zeros(sz);  y0 = zeros(sz);

% parallel lines (do not intersect except for similar lines)
% for similar lines, take the low and high points
idx = find( abs(m1-m2)<err | (isinf(m1)&isinf(m2)) );
if ~isempty(idx)
% non-similar lines
% 	sub = find(b1(idx)~=b2(idx));  j = idx(sub);
	sub = find(abs(b1(idx)-b2(idx))>err);  j = idx(sub);
	x0(j) = nan;  y0(j) = nan;
% similar lines (non-vertical)
% 	sub = find(b1(idx)==b2(idx) & m1(idx)~=inf);  j = idx(sub);
	sub = find(abs(b1(idx)-b2(idx))<err & m1(idx)~=inf);  j = idx(sub);
	Xlo = max([min(X1(j,:),[],2) min(X2(j,:),[],2)],[],2);
	Xhi = min([max(X1(j,:),[],2) max(X2(j,:),[],2)],[],2);
	if ~isempty(j)
		j0 = find(abs(Xlo-Xhi)<=err);
		j1 = find(abs(Xlo-Xhi)>err);
		x0(j(j0)) = Xlo(j0);
		y0(j(j0)) = Y1(j(j0)) + m1(j(j0)).*(Xlo(j0) - X1(j(j0)));
		x0(j(j1)) = Xlo(j1) + i*Xhi(j1);
		y0(j(j1)) = (Y1(j(j1)) + m1(j(j1)).*(Xlo(j1) - X1(j(j1)))) + ...
					 i*(Y1(j(j1)) + m1(j(j1)).*(Xhi(j1) - X1(j(j1))));
	end
% similar lines (vertical)
% 	sub = find(b1(idx)==b2(idx) & m1(idx)==inf);  j = idx(sub);
	sub = find(abs(b1(idx)-b2(idx))<err & m1(idx)==inf);  j = idx(sub);
	Ylo = max([min(Y1(j,:),[],2) min(Y2(j,:),[],2)],[],2);
	Yhi = min([max(Y1(j,:),[],2) max(Y2(j,:),[],2)],[],2);
	if ~isempty(j)
		y0(j) = Ylo + i*Yhi;
		x0(j) = X1(j) + i*X1(j);
	end
end

% non-parallel lines
idx = find(abs(m1-m2)>err);
if ~isempty(idx)
% non-vertical/non-horizontal lines
% 	sub = find(m1(idx)~=inf & m2(idx)~=inf & m1(idx)~=0 & m2(idx)~=0);
	sub = find(m1(idx)~=inf & m2(idx)~=inf & ...
			   abs(m1(idx))>eps & abs(m2(idx))>eps);
	j = idx(sub);
	x0(j) = (Y1(j) - Y2(j) + m2(j).*X2(j) - m1(j).*X1(j)) ./ ...
			(m2(j) - m1(j));
	y0(j) = Y1(j) + m1(j).*(x0(j)-X1(j));
% first line vertical
	sub = find(m1(idx)==inf);  j = idx(sub);
	x0(j) = X1(j);
	y0(j) = Y2(j) + m2(j).*(x0(j)-X2(j));
% second line vertical
	sub = find(m2(idx)==inf);  j = idx(sub);
	x0(j) = X2(j);
	y0(j) = Y1(j) + m1(j).*(x0(j)-X1(j));
% first line horizontal, second line non-vertical
	sub = find(abs(m1(idx))<=eps & m2(idx)~=inf);  j = idx(sub);
	y0(j) = Y1(j);
	x0(j) = (Y1(j) - Y2(j) + m2(j).*X2(j)) ./ m2(j);
% second line horizontal, first line non-vertical
	sub = find(abs(m2(idx))<=eps & m1(idx)~=inf);  j = idx(sub);
	y0(j) = Y2(j);
	x0(j) = (Y1(j) - y0(j) - m1(j).*X1(j)) ./ -m1(j);
end

% throw away points that lie outside of line segments
dx1 = [min(X1,[],2)-x0, x0-max(X1,[],2)];
dy1 = [min(Y1,[],2)-y0, y0-max(Y1,[],2)];
dx2 = [min(X2,[],2)-x0, x0-max(X2,[],2)];
dy2 = [min(Y2,[],2)-y0, y0-max(Y2,[],2)];
% [irow,icol] = find([dx1 dy1 dx2 dy2]>1e-14);
[irow,icol] = find([dx1 dy1 dx2 dy2]>err);
idx = sort(unique(irow));
x0(idx) = nan;
y0(idx) = nan;

% retrieve only intersection points (no nans)
idx = find(~isnan(x0));
xi = x0(idx);  yi = y0(idx);

% determine indices of line segments that intersect
i1 = ceil(idx/N2);  i2 = rem(idx,N2);
if ~isempty(i2),  i2(find(i2==0)) = N2;  end
ii = [i1 i2];

% combine all intersection points
indx = union(find(imag(xi)),find(imag(yi)));
% indx = find(imag(xi));
for n=length(indx):-1:1
	j = indx(n);
	ii = [ii(1:j-1,:); ii(j,:); ii(j:end,:)];
	xi = [xi(1:j-1); imag(xi(j)); real(xi(j:end))];
	yi = [yi(1:j-1); imag(yi(j)); real(yi(j:end))];
end

% check for identical intersection points (numerical error in epsilon)
[xt,ixt,jxt] = sap_uerror(xi,[],err);
[yt,iyt,jyt] = sap_uerror(yi,[],err);
xi = xt(jxt);  yi = yt(jyt);
[xi,yi] = sap_perror(xi,yi,[x1;x2],[y1;y2],err);