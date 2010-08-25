function PUdata = roi_smoothROI(PUdata,idxPU,dim,rho,Vmat)
% ROI_SMOOTHROI(PUDATA,IDXPU,DIM,RHO) smooths an ROI in a volume of
% size DIM indexed by IDXPU containing data PUDATA with a smoothing
% FWHM parameter specified in mm and the transformation matrix of
% the volume specified in Vmat.
%
% See also: ROI_CREATE_ROI_DATA, 

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Satrajit Ghosh

s=rho;

% See spm_smooth_vol, spm_conv_vol for details
VOX = sqrt(sum(Vmat(1:3,1:3).^2));

s  = s./VOX;% voxel anisotropy
s  = max(s,ones(size(s)));% lower bound on FWHM
s  = s/sqrt(8*log(2));% FWHM -> Gaussian parameter

if 0,
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

Y = zeros(dim(1:3));
for nscan = 1:size(PUdata,1),
    Y(:) = 0;
    Y(idxPU) = PUdata(nscan,:)';
    spm_conv_vol(Y,Y,x,y,z,-[i,j,k]);
    PUdata(nscan,:) = Y(idxPU');
end
end;

% Old code from Alfonso
%rho=rho/sqrt(8*log(2));
rho = s(1);
[x,y,z] = ind2sub(dim(1:3),idxPU);
XYZ = [x,y,z]';
% Following taken from Alfonso's code
dXYZ=exp(-(shiftdim(sum(abs(permute(XYZ(:,:,ones(size(XYZ,2),1)),[1,3,2])-XYZ(:,:,ones(size(XYZ,2),1))).^2,1),1))/2/rho.^2);
sdXYZ=sum(dXYZ,1); dXYZ=dXYZ./sdXYZ(ones(size(dXYZ,1),1),:);
PUdata=PUdata*dXYZ;               % Intra-region smooth 

