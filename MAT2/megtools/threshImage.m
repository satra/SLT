function [v] = threshImage(ImageGridAmp)
ImageGridAmp = double(ImageGridAmp); 
minv = min(ImageGridAmp,[],2);
maxv = max(ImageGridAmp,[],2);
v = (abs(minv - mean(minv)) > 3*std(minv)) | (abs(maxv - mean(maxv)) > 3*std(maxv));
%v = max(abs(minv - mean(minv)),(abs(maxv - mean(maxv))));
