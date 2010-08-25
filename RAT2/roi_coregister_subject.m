function roi_coregister_subject(PG,PF,PO)
% ROI_COREGISTER_SUBJECT Coregisters functionals with the structural image
%   ROI_COREGISTER_SUBJECT(PG,PF) coregisters the image PF with the image
%   PG and updates the MAT file associated with PF. It does not reslice PF.
%   
%   ROI_COREGISTER_SUBJECT(PG,PF,PO) performs the same function as above,
%   but in addition brings along all the files in the character array PO to
%   be coregistered with PG, assuming PO was already coregistered with PF
%   PO = spm_get(Inf,'IMAGE', ['Other images, subj 1']);
%
% See also: ROI_PREPROCESS_SUBJECTS

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

spm_defaults;
global defaults

if nargin<3,
    PO = '';
end

VG = spm_vol(PG);
VF = spm_vol(PF);

flags = defaults.coreg;
x  = spm_coreg(VG,VF,flags.estimate);

PO = str2mat(PF,PO);
M  = inv(spm_matrix(x));
MM = zeros(4,4,size(PO,1));
for j=1:size(PO,1),
    MM(:,:,j) = spm_get_space(deblank(PO(j,:)));
end;
for j=1:size(PO,1),
    spm_get_space(deblank(PO(j,:)), M*MM(:,:,j));
end;
