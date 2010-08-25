function dsurf = divideSurf(surf,N)

v = surf.vertices;
minv = min(v);
maxv = max(v);
dims = [maxv-minv];
%volv = prod([maxv-minv]);
