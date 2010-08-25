if ~exist('mc'),
surfstruct = preprocess(fv);

[mc, gc] = curvature(surfstruct);
mc = abscurvature(surfstruct,mc);
end;

fp = getsulcpatches(surfstruct,mc);
return;

for i=1:length(fp),
    mc1 = mc;
    %mc1(fp(i).verts) = 0;
    %eulerNumber(extractPatch(testsurf,fp(i).verts))
    p.vertices = surfstruct.vertices;
    p.faces = extractFaces(surfstruct,fp(i).verts,2);
    %bv = borderVertices(preprocess(p));
    %mc1(fp(i).verts(bv)) = 0;
    vertidx = unique(p.faces(:));
    mc1(vertidx) = 2;
    showVertexValue(inflatedSurf, mc1);
    drawnow;
end;
