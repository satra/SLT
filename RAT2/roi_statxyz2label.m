function [label,idx,pval] = roi_statxyz2label(xyz,Tval,Cval)
% xyz = [3xN] significant voxels in the brain
% Tval= significance level T-value
% Cval= Effect size of voxel

[pn,fn,xt] = fileparts(which(mfilename));
V = spm_vol(fullfile(pn,'..','aal','ROI_MNI_V4.img'));
Y = spm_read_vols(V);

N = size(xyz,2);
xyz_vol = pinv(V.mat)*[xyz;ones(1,N)];
xyz_vol = max(round(xyz_vol(1:3,:)),1)';
idx_vol = sub2ind(V.dim(1:3),xyz_vol(:,1),xyz_vol(:,2),xyz_vol(:,3));
id = Y(idx_vol);

% Generate list of active regions
[id,idx] = unique(id(:));

idx = idx(find(id));
id  = id(find(id));

pval = [];

for n0=1:length(id),
    % Determine the most significant voxel in the region
    % Tval or Cval .. that is the question!
    %[maxval,idx(n0)] = max((Y(idx_vol)==id(n0)).*Cval.*(Tval>0));
    
    % Determine if the region as a whole is active
    ROI = zeros(size(Y));
    ROI(idx_vol) = Cval;
    ROI = ROI(find(Y(:)==id(n0)));
    [h,pval(n0)] = ttest(ROI);
end

%[pu_id,pu_label,some_no]
%=textread('/speechlab/software/SLT/RAT2/aal.txt','%d%s%d\n');
fn = fullfile(pn,'..','aal','ROI_MNI_V4_List');
load(fn);
roi_id = [ROI(:).ID]';
roi_label = {ROI(:).Nom_L}';
pu_label(roi_id) = roi_label;

label = pu_label(id);
