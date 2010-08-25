function roi_smooth_subject(PF,varargin)
% ROI_SMOOTH_SUBJECT Smooths the list of files named
%   ROI_SMOOTH_SUBJECT(PF) smooths all the files listed in the character
%   array PF with the optional smoothing argument provided in
%   varargin{1}. 
%
% See also: ROI_PREPROCESS_SUBJECTS

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

if nargin<2,
    smoothFWHM = 12;
else,
    smoothFWHM = varargin{1};
end

if ischar(PF),
    PF = spm_vol(PF);
end;
for i=1:size(PF,1),
        [pth,nam,ext] = fileparts(PF(i,:).fname);
        fname         = fullfile(pth,['pp_' nam ext]);
        spm_smooth(PF(i,:),fname,smoothFWHM);
end;
