function roi_fullnormalize_subject(PF,PO)
% ROI_FULLNORMALIZE_SUBJECT Performs affine normalization Structural
% images
%   ROI_FULLNORMALIZE_SUBJECT(PF) Takes the analyze filename and
%   normalizes it to the template T1.mnc and writes the normalized file and
%   the parameters in the same directory as original data
%
%   ROI_FULLNORMALIZE_SUBJECT(PF,PO) applies the same transformation to
%   all the remaining images specified in PO
%
%   If the normalized image exists, then no normalization is performed, but
%   for any image brought along a normalized version of that image is
%   written.
%
% See also: ROI_PREPROCESS_SUBJECTS

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

spm_defaults;
defs = defaults.normalise;

roi_write_log('roi_fullnormalize_subject: Start');
VG = fullfile(spm('dir'),'templates','T1.mnc');
matname = [spm_str_manip(PF,'sd') '_fullsn.mat'];
if ~exist(matname,'file'),
    VWG ='';
    VWF ='';
    flags = defs.estimate;
    spm_normalise(VG,PF,matname,VWG,VWF,flags);

    flags = defs.write;
    % Write the structural image with a high resolution
    flags.vox = [1 1 1];
    spm_write_sn(PF,matname,flags);
    %spm_write_sn(PF,matname,flags);
end;

if nargin==2,
    flags = defs.write;
    % Assuming the PO generally contains the hires and functional images, they
    % are written with a lower resolution.
    spm_write_sn(PO,matname,flags);
    %spm_write_sn(PO,matname,flags);
end;

roi_write_log('roi_fullnormalize_subject: Done');
