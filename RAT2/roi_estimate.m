function roi_estimate(SPMmatfile);
% SPM = ROI_ESTIMATE(SPMMATFILE) performs GLM estimation on the
% experimental design stored in the SPMMATFILE. Since the
% SPMMATFILE is large and certain parts of it get modified during
% the estimation, a filename instead of the structure is passed to
% the program
%
% See also: ROI_FIXEDFX_SUBJECTS

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

%load(SPMmatfile);
spm_spm(SPMmatfile);
