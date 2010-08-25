%function [inflatedSurf,testsurf,mc,mc1,mc2,map]=surfProcess(surfstruct);

load cmapdata;
figure;
colormap(map);
view(-94,20);

[mc, gc] = curvature(surfstruct);
mc = abscurvature(surfstruct,mc);
cla;
showVertexValue(surfstruct, mc);
drawnow;
%inflatedSurf = motionByMeanCurv(surfstruct, 2, 400, 1, 0, 0, 1);
inflatedSurf = motionByMeanCurv(surfstruct, 400, 1.2);
cla;
showVertexValue(inflatedSurf, mc);
drawnow;

vertNormals = computeNormals(surfstruct);
mc1 = zeros(size(mc));
load roidata;
for i=0:2:25,
    idx = find(mc1<1);
    querypos(idx,:) = surfstruct.vertices(idx,:) + (i*0.1)*vertNormals(idx,:);
    querypos(idx,2) = querypos(idx,2)/3;
    querypos = round(querypos);
    ind = sub2ind(size(roidata),querypos(:,1),querypos(:,2),querypos(:,3));
    mc1 = round(roidata(ind));
    mc2 = (mc+1)/2;
    mc2(find(mc1)) = mc1(find(mc1));
    cla;
    showVertexValue(inflatedSurf, mc2);
    drawnow;
end;
clear roidata idx

%testsurf = inflatedSurf;
%testsurf = sphereSurf(testsurf,mc);

labels = unique(mc1);
labels = labels(find(labels));

foo1 = zeros(size(mc));
for i=labels(:)',
    foo=(abscurvature(inflatedSurf,2*(mc1==i)-1)+1)/2;
    %disp('a');unique(foo)
    foo1 = foo1+i*(foo.*(foo1<1));
    %disp('b');unique(foo1)
end;
foo2 = foo1; %zeros(size(mc));
foo2(find(foo1==0)) = (mc(find(foo1==0))+1)/2;
cla;
showVertexValue(inflatedSurf,foo2);
drawnow;

fv.vertices = inflatedSurf.vertices;
ROIpatch = {};
for i=labels(:)',
    patchfaces = extractFaces(inflatedSurf,find(foo2==i),1);
    ROIpatch{i}.faces = patchfaces;
    vertidx = unique(patchfaces(:));
    meanv = mean(fv.vertices(vertidx,:));
    dist = fv.vertices(vertidx,:)-repmat(meanv,length(vertidx),1);
    [minval,minidx] = min(sqrt(sum(dist.^2,2)));
    ROIpatch{i}.centerpatch = fv.vertices(vertidx(minidx),:);
    %p = patch(fv,'FaceVertexCData',(foo2==i),'Facecolor','interp','Edgecolor','none');
    %pause;
    %delete(p);
end;

ph = [];
for i=labels(:)',
    centerpatch = ROIpatch{i}.centerpatch;
    ph = [ph;plot3(centerpatch(1),centerpatch(2),centerpatch(3),'ro')];
end;

if 0,
    verts = testsurf.vertices;
    verts1 = verts-repmat(mean(verts),length(verts),1);
    [lambda,phi,r] = cart2sph(verts1(:,1),verts1(:,2),verts1(:,3));
    fidx = zeros(length(testsurf.faces),1);
    f = testsurf.faces;
    c = computeCentroids(testsurf);
    c = c-repmat(mean(verts),length(c),1);
    [lambda1,phi1,r1] = cart2sph(c(:,1),c(:,2),c(:,3));
    scf = 180/pi;
    hproc = uiwaitbar('Wait');
    for i=1:length(fidx),
        rf = (i+1):length(fidx);
        cdist = repmat(c(i,:),length(rf),1)-c(rf,:);
        cdist = sqrt(sum(cdist.^2,2));
        [sval,idx] = min(cdist);
        if sval<0.1,
            ai = areaint(scf*phi(f(i,:)),scf*lambda(f(i,:)));
            aj = areaint(scf*[phi(f(i,:));phi1(idx)],scf*[lambda(f(i,:));lambda1(idx)]);
            if abs(ai-aj)==0,
                fidx([i,idx]) = 1;
            end;
        end;
        if mod(i,10)==0,
            uiwaitbar(i/length(fidx),hproc);
        end;
    end;
    delete(hproc);
    
    
    fv.vertices = rightsurf.vertices;
    fv.faces = rightsurf.faces;
    p = patch(fv,'FaceVertexCData',round(mc),'Facecolor','interp','Edgecolor','none');
    %map = [[0.5 0.5 0.5;0.75 0.75 0.75];jet(35)];
    a = vga;
    map = [[0.5 0.5 0.5;0.75 0.75 0.75];a;a;a(3,:)];
    colormap(map);
    axis off;
    axis equal;
    lighting gouraud;
    shading interp;
    material dull;
    view(-94,20);
end;