function vol = roi_smoothVol(vol,VOX,FWHM)

% This section does smoothing using spm. 
s = FWHM;
s  = s./VOX;% voxel anisotropy
s  = max(s,ones(size(s)));% lower bound on FWHM
s  = s/sqrt(8*log(2));% FWHM -> Gaussian parameter

x  = round(6*s(1)); x = [-x:x];
y  = round(6*s(2)); y = [-y:y];
z  = round(6*s(3)); z = [-z:z];
x  = exp(-(x).^2/(2*(s(1)).^2)); 
y  = exp(-(y).^2/(2*(s(2)).^2)); 
z  = exp(-(z).^2/(2*(s(3)).^2));
x  = x/sum(x);
y  = y/sum(y);
z  = z/sum(z);

i  = (length(x) - 1)/2;
j  = (length(y) - 1)/2;
k  = (length(z) - 1)/2;

spm_conv_vol(vol,vol,x,y,z,-[i,j,k]);
% done smoothing

