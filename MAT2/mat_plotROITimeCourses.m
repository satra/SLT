rois = {'aSMA','pSMA','vPMC','vMC','aINS','H'};
times = [-499:1000];
figure;
[id,nm,rr,gg,bb,dum] = textread('/speechlab/software/freesurfer/surface_labels.txt','%d%s%d%d%d%d');

for i=1:length(rois),
    roiPUID = find(strcmp(rois{i},nm))-1
    vertList = find(lowResPUIDLabels==roiPUID);
    vertList = vertList(vertList < 33000);
    roiData = double(ImageGridAmp(vertList,:));
    %[u,s,v] = svd(roiData');
    subplot(ceil(length(rois))/2,2,i);
    %plot(u(1:length(times),1:3));
    %newtime = u(1:length(times),1:3)*diag(s(1:3))*v(:,1:3)';
    %   plot(newtime);
    %axis([min(times) max(times) -1 1]);
   plot(mean(roiData));
   set(gca,'XTick',0:100:1500,'XTickLabel',[-500:100:1000]);
   title(rois{i});
   
   % title(sprintf('%s%2.2f%2.2f%2.2f',rois{i},s(1),s(2),s(3)));
end;
