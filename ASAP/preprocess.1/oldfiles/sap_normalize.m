function sap_normalize(V)
% SAP_NORMALIZE Perform affine normalization on a single T1 weighted image

global sptl_BB SWD

%sptl_BB = [[-90 -126 -72];[91 91 109]];

spm('defaults','FMRI');

DIR1   = fullfile(SWD,'templates');
DIR2   = fullfile(SWD,'apriori');

[pth,nm,xt,vr] = fileparts(deblank(V.fname));
matname = sprintf('%s_sn3d.mat',[pth filesep nm]);
if exist(matname,'file'),
    return;
end;

bb = sptl_BB;
params = [0 0 0 0 8 0];
spms = fullfile(DIR1,'T1.img');
brainmask = fullfile(DIR2,'brainmask.img');
objmask = [''];
vox = diag(V.mat);
vox = vox(1:3)';
vox = [1 1 1];

%spm_sn3d(strtok(V.fname,'.'),matname,bb,vox,params,spms,brainmask,objmask);
%spm_write_sn(strtok(V.fname,'.'),matname,bb,vox,1);
spm_sn3d(V.fname,matname,bb,vox,params,spms,brainmask,objmask);
spm_write_sn(V.fname,matname,bb,vox,1);