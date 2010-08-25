function roifs_hemiequal(template)
% hemiequal('nROImask_*.img');
% This program ensures that the ROI values are the same on both sides of the 
% brain. 
% Turns out the noscale option in mri_convert is bloody useless
% Since the new version of mri_convert "supposedly" doesn't scale the
% values in the image, we do not require setting the max value to 255. Also, 
% FreeSurfer reads in version 4 mat files so the orientation matrix is saved
% as a mat file.

spm_defaults;
filenames = spm_get('files',pwd,template);
for i=1:size(filenames,1),
    fname = filenames(i,:);
    [pth,nm,xt] = fileparts(fname);
    V = spm_vol(fname);
    Y = round(spm_read_vols(V));
    Y = (Y-32000).*(Y>32000)+Y.*(Y<32000);
    idx = find(Y(:)==0);
    Y(idx) = 3;
    %Y(1:5,1:5,1:5) = spm_type(V.dim(4),'maxval');
    V.fname = fullfile(pth,['e',nm,xt]);
    V.pinfo = [1 0 0]';
    V2 = spm_create_vol(V);
    for p=1:V2.dim(3)
        spm_write_plane(V2, Y(:, :, p), p);
    end
    %spm_write_vol(V,Y);
    if ~exist(fullfile(pth,['e',nm,'.mat']),'file'),
	M = V.mat;
	save(fullfile(pth,['e',nm,'.mat']),'M','-V4');
    end;
end;
