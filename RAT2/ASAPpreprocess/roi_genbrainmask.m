function roi_genbrainmask(filename);
% ROI_GENBRAINMASK Segments the normalized brain and generates a brain mask

spm_defaults;
flags = defaults.segment;

roi_write_log('roi_genbrainmask: Performing segmentation');
[pth,nm,xt] = fileparts(filename);
if isempty(pth),
    pth = pwd;
end;
    
V = spm_vol(filename);
SG = fullfile(pth,[nm,'_seg1',xt]);
if ~exist(SG,'file'),
    spm_segment(V,eye(4),flags);
end;

suffix = [pth,filesep,'m',nm,'_'];

if exist([suffix, 'brainmask.mat'],'file'),
    roi_write_log('sap_segment: Brainmask exists Done');
    return;
end;

VG = spm_vol(fullfile(pth,[nm,'_seg1',xt]));
VW = spm_vol(fullfile(pth,[nm,'_seg2',xt]));
% Brain is initially set to white matter...
%-----------------------------------------------------------------------
br=zeros(VW.dim(1:3));
for i=1:VW.dim(3),
	br(:,:,i) = spm_slice_vol(VW,spm_matrix([0 0 i]),VW.dim(1:2),1);
end;

% Build a 3x3x3 seperable smoothing kernel
%-----------------------------------------------------------------------
kx=[0.75 1 0.75];
ky=[0.75 1 0.75];
kz=[0.75 1 0.75];
sm=sum(kron(kron(kz,ky),kx))^(1/3);
kx=kx/sm; ky=ky/sm; kz=kz/sm;

% Erosions and conditional dilations
%-----------------------------------------------------------------------
niter = 32;
spm_progress_bar('Init',niter,'Extracting Brain','Iterations completed');
for j=1:niter,
	if j>2, th=0.15; else, th=0.6; end; % Dilate after two its of erosion. 
	for i=1:VW.dim(3),
		w=spm_slice_vol(VW,spm_matrix([0 0 i]),VW.dim(1:2),1);
		g=spm_slice_vol(VG,spm_matrix([0 0 i]),VW.dim(1:2),1);
		br(:,:,i) = (br(:,:,i)>th).*(w+g);
	end;
	spm_conv_vol(br,br,kx,ky,kz,-[1 1 1]);
	spm_progress_bar('Set',j);
end;
spm_progress_bar('Clear');

brainmask = uint8(255*((br-min(br(:)))/(max(br(:))-min(br(:)))));
save([suffix,'brainmask.mat'],'brainmask');

% 
% keyboard;
% 
% VB = spm_vol(fullfile(pth,['m',nm,xt]));
% VG = spm_vol(fullfile(pth,[nm,'_seg1',xt]));
% VW = spm_vol(fullfile(pth,[nm,'_seg2',xt]));
% VC = spm_vol(fullfile(pth,[nm,'_seg3',xt]));
% 
% YB = spm_read_vols(VB);
% YG = spm_read_vols(VG);
% YW = spm_read_vols(VW);
% YC = spm_read_vols(VC);
% 
% 
% N = 89;
% IB = squeeze(YB(:,N,:))';
% IG = squeeze(YG(:,N,:))';
% IW = squeeze(YW(:,N,:))';
% IC = squeeze(YC(:,N,:))';
% 
% figure;
% colormap gray;
% imagesc(IB);axis image;axis xy;hold on;
% contour(IG>0.3 & IW<0.5 & IC<0.7,[1 1],'g');
% contour(IG>0 | IW>0,[1 1],'r');


roi_write_log('roi_genbrainmask: Done');