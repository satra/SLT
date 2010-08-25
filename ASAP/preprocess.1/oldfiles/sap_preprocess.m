function H = sap_preprocess(imgname1,imgname2)

if nargin == 1,
    V = spm_vol(imgname1);
elseif nargin == 2,
    V1 = spm_vol(imgname1);
    V2 = spm_vol(imgname2);
    Y1 = spm_read_vols(V1);
    Y2 = spm_read_vols(V2);
    Y3 = Y1+Y2;
    clear T1 Y2;
    Y3 = uint16(65535*Y3/max(Y3(:)));
    V1.fname = sprintf('%s_avg',strtok(imgname1,'_'));
    spm_write_vol(V1,Y3);
    sap_preprocess(V1.fname);
    return;
else,
    error('Incorrect number of arguments');
end;

global SWD;
spm('defaults','FMRI');
DIR1   = fullfile(SWD,'templates');

[pth,nm,xt,vr] = fileparts(deblank(V.fname));
fname1 = nm;
PF = [pth filesep nm xt];
PG = fullfile(DIR1, 'T1.img');
PG = '';
opts = 'wc';

if ~exist(sprintf('%s_seg1.img',[pth filesep nm]),'file'),
    spm_segment(PF,PG,opts);
end;
suffix = [pth,filesep,'corr_',nm,'_'];
if exist([suffix, 'brainmask.mat'],'file'),
    return;
end;

linfun = inline('fprintf([''%-10s''],x)','x');

VG=spm_vol(sprintf('%s_seg1',[pth filesep nm]));	% Grey matter
VW=spm_vol(sprintf('%s_seg2',[pth filesep nm]));	% White matter

% Brain is initially set to white matter...
%-----------------------------------------------------------------------
br=zeros(VW.dim(1:3));
linfun('Initialising');
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
%spm_progress_bar('Init',niter,'Extracting Brain','Iterations completed');
%hwait = waitbar(0,'Extracting brain mask','units','normalized','Position',[0.1 0.1 0.35 0.1]);
hwait = uiwaitbar('Extracting brain mask');
for j=1:niter,
    if j>2, th=0.15; else, th=0.6; end; % Dilate after two its of erosion. 
    linfun(['Iteration ' num2str(j) ' - thresholding and multiplying']);
    for i=1:VW.dim(3),
        w=spm_slice_vol(VW,spm_matrix([0 0 i]),VW.dim(1:2),1);
        g=spm_slice_vol(VG,spm_matrix([0 0 i]),VW.dim(1:2),1);
        br(:,:,i) = (br(:,:,i)>th).*(w+g);
    end;
    linfun(['Iteration ' num2str(j) ' - convolving']);
    spm_conv_vol(br,br,kx,ky,kz,-[1 1 1]);
    uiwaitbar(j/niter,hwait);
    %	spm_progress_bar('Set',j);
end;
%spm_progress_bar('Clear');
delete(hwait);

brainmask = uint8(255*((br-min(br(:)))/(max(br(:))-min(br(:)))));
clear br;

save([suffix,'brainmask'],'brainmask');
if nargout == 1,
    H.Image.DataType = 2; %signifies uint8 in SPM
    H.Crop = 0;	%Display whole data sent in PAST
    H.draw = 0;
    V1 = spm_vol(fname1);
    vox = diag(V1.mat);
    vox = vox(1:3)';
    H.Image.Ratio_X = vox(1);
    H.Image.Ratio_Y = vox(2);
    H.Image.Ratio_Z = vox(3);
    H.Image.MatrixSize_X = V1.dim(1);
    H.Image.MatrixSize_Y = V1.dim(2);
    H.Image.MatrixSize_Z = V1.dim(3);
    
    H.mask	= brainmask;
    H.fname	= fname1;
end;