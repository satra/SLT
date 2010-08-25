function fp = getsulcpatches(surfstruct,mc)

vertidx = find(mc>0);
count = 0;
while length(vertidx),
    verts = growvertex(surfstruct,vertidx(1),mc);
    count = count+1;
    fp(count).vertid = vertidx(1);
    fp(count).verts = verts;
    fp(count).num = length(verts);
    fprintf('vert id[%d]-->patchcount[%d]-->patchsize[%d]\n',...
        vertidx(1),count,length(verts));
    vertidx = setdiff(vertidx,verts);
end;

[val,vid] = sort([fp(:).num]);
fp = fp(vid([end:-1:1]'));