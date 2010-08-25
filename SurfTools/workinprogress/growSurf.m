function growSurf(surf)

v = surf.vertices;
f = surf.faces;

fv.vertices = v;
fv.faces = f;
[mc,GC,K1,K2,MN,normals] = curvature( surf );
clear surf;
v1 = v;

figure('doublebuffer','on');
for i=1:10,
    v1 = v1 + normals*0.1*i;
    %tic;vint = collisionMEX(v1,int32(f-1));toc;
    %idx = find(~vint);
    %v(idx) = v1(idx);
    fv.vertices = v1;
    showVertexValueDirect(fv,mc);view(113,9);camlight headlight;drawnow;
end;