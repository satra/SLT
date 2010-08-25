
maxAmp = max(max(ImageGridAmp));
minAmp = min(min(ImageGridAmp));
cMap = gray(256);

colormap(pink);
figure;
h = trisurf(Faces{1},Vertices{1}(1,:),Vertices{1}(2,:),Vertices{1}(3,:),'FaceAlpha',1.0);
set(h,'FaceLighting','gouraud');
%light;
w = waitbar(0,'Time','xlabel','Time(ms)');
j = 1;
%M = moviein(length(1:1:501));
for i=1:1:501,
    faceColors = mean([ImageGridAmp(Faces{1}(:,1),i) ImageGridAmp(Faces{1}(:,2),i) ImageGridAmp(Faces{1}(:,3),i)],2);
    faceColors = (faceColors - minAmp) ./ (maxAmp - minAmp);
    %faceMap = cMap(ceil(faceColors*64),:);  
    
    h = trisurf(Faces{1},Vertices{1}(1,:),Vertices{1}(2,:),Vertices{1}(3,:),'FaceAlpha',1.0,'cData',faceColors);
    set(h,'CData',ceil(faceColors*128),'CDataMapping','direct');
    drawnow;
    %M(:,j) = getframe;
    j = j+1;
    waitbar(i/501,w);
end;



