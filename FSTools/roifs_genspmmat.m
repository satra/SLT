function roifs_genspmmat(subjdir,template)
% To run this for 10 subjects:
% for i=1:14,roifs_genspmmat(pwd,sprintf('wROImask*%02d.Series*.img',i));end;

spm_defaults;
filename = spm_get('files',subjdir,template);
V = spm_vol(filename);
M = V.mat;
[pth,nm,xt] = fileparts(filename);
save(fullfile(pth,[nm,'.mat']),'M','-V4');
