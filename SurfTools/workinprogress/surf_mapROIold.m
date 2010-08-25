%function ROIpatch = surf_mapROI(ROImask_filename,surffile)
% SURF_MAPROI Maps the ROIs generated with ASAP onto a brain surface

ROImask_filename = 'ROImask_corr_nsubject.08.Series.004.img';
ROImask_filename = 'nROImask_corr_nsubject.09.Series.003.img';
surffile = 'corr_nsubject.09.Series.003_leftsurf.mat';

% Load ROI mask and surface
V = spm_vol(ROImask_filename);
roidata = round(spm_read_vols(V));
roidata = (roidata-32000).*(roidata>=32000);
load(surffile);

% Assign ROI label to each vertex by marching outwards in the direction
% of the normal
vertNormals = computeNormals(surfstruct);

mc1 = zeros(size(mc));
for i=0:2:30; %25,
    idx = find(mc1<1);
    querypos(idx,:) = surfstruct.vertices(idx,:) + (i*0.1)*vertNormals(idx,:);
    querypos = round(querypos);
    querypos(:,1) = max(1,min(querypos(:,1),size(roidata,1)));
    querypos(:,2) = max(1,min(querypos(:,2),size(roidata,2)));
    querypos(:,3) = max(1,min(querypos(:,3),size(roidata,3)));
    ind = sub2ind(size(roidata),querypos(:,1),querypos(:,2),querypos(:,3));
    mc1 = round(roidata(ind));
    mc2 = (mc+1)/2;
    mc2(find(mc1)) = mc1(find(mc1));
    showVertexValue(surfstruct, mc2);view(-123,23);
    drawnow;
end;
clear roidata idx
showVertexValue(inflatedSurf,mc2);view(-113,9);
drawnow;


labels = unique(mc1);
labels = labels(find(labels));
inflatedSurf = preprocess(inflatedSurf);

% smooth the labels
foo1 = zeros(size(mc));
hproc = uiwaitbar('Smoothing labels');
for i=labels(:)',
    foo=(abscurvature(inflatedSurf,2*(mc1==i)-1)+1)/2;
    %disp('a');unique(foo)
    foo1 = foo1+i*(foo.*(foo1<1));
    %disp('b');unique(foo1)
    uiwaitbar(find(i==labels)/length(labels),hproc);
end;
delete(hproc);
foo2 = foo1; %zeros(size(mc));
foo2(find(foo1==0)) = (mc(find(foo1==0))+1)/2;
showVertexValueDirect(inflatedSurf,foo2);view(-113,9);
drawnow;
return;

[PU,id] = sap_PUlist;

% get patches for each ROI
fv.vertices = inflatedSurf.vertices;
ROIpatch = {};
for i=labels(:)',
    numverts = find(foo2==i);
    if ~isempty(numverts),
        [patchfaces,faceids] = extractFaces(inflatedSurf,numverts,2);
        ROIpatch{i}.faces = patchfaces;
        ROIpatch{i}.faceids = faceids;
        vertidx = unique(patchfaces(:));
        meanv = mean(fv.vertices(vertidx,:));
        dist = fv.vertices(vertidx,:)-repmat(meanv,length(vertidx),1);
        [minval,minidx] = min(sqrt(sum(dist.^2,2)));
        ROIpatch{i}.centerpatch = fv.vertices(vertidx(minidx),:);
        %p = patch(fv,'FaceVertexCData',(foo2==i),'Facecolor','interp','Edgecolor','none');
        %showVertexValue(inflatedSurf,3*(foo2==i)+mc.*(foo2~=i));
        %title(sprintf('PU=%s',PU{find(i==id | (i-200)==id)}));
        %view(113,9);
        %pause;
    end;
end;

% Plot centers on the patch
% hold on;
% ph = [];
% for i=labels(:)',
%     centerpatch = ROIpatch{i}.centerpatch;
%     ph = [ph;plot3(centerpatch(1),centerpatch(2),centerpatch(3),'ro')];
% end;
% hold off;
