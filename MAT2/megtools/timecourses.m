load jb_last_data_results_1944.mat ImageGridAmp

%maxd = max(ImageGridAmp(:,1:500)');
%mind = min(ImageGridAmp(:,1:500)');
%aveMax = mean(maxd)
%stdMax = std(maxd)
%aveMin = mean(mind)
%stdMin = std(mind)
z = zeros(size(ImageGridAmp,1),1);
for i=1:8,
    N = ceil(length(ImageGridAmp)/8);
    idx = [((i-1)*N+1):min(i*N,length(ImageGridAmp))];
    z(idx,1) = threshImage1(ImageGridAmp(idx,:));
end;

activeIndices = find(z>0);
length(activeIndices)

%load good_white_tesselation;
load deeper_tesselation;

surf.vertices = Vertices{1}';
surf.faces = Faces{1};

figure;
map = colormap(gray);
vertexData = ones(length(Vertices{1}),1)*32;
vertexData(activeIndices) = 128;
material dull;
showVertexValueDirect(surf,vertexData);
%colorbar;
%light;



