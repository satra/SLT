function roi_segment(filename);

spm_defaults;
flags = defaults.segment;

roi_write_log('roi_segment: Performing segmentation');
[pth,nm,xt] = fileparts(filename);
if isempty(pth),
    pth = pwd;
end;

V = spm_vol(filename);
roi_write_log(['roi_segment: ',V.fname]);
SG = fullfile(pth,[nm,'_seg1',xt]);
if ~exist(SG,'file'),
    spm_segment(V,eye(4),flags);
    spm_surf(SG,1,0);
end;

