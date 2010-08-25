function roi_realign_subject(P,realign2mean)
% ROI_REALIGN_SUBJECT Realigns the functional images to the first image
%   ROI_REALIGN_SUBJECT(P) realigns the images in each session, to the
%   first image in the first session. This function justs creates/updates
%   the *.mat files associated with the images. It does not reslice the
%   images themselves. P is a cell matrix where each cell contains each
%   session information
%   P             = cell(1,N);
%   P{1,1}        = spm_get(Inf,'*IMAGE','Scans for session 1');
%   P{1,2}        = spm_get(Inf,'*IMAGE','Scans for session 2');
%
%   [TODO]
%   ROI_REALIGN_SUBJECT(P,realign2mean) does the same thing as above except
%   that it realigns all the images to the mean image. I'm still working on
%   what this does exactly and how to have realign create the mean
%   image. This new image will need to be coregistered with the
%   structural instead of the hi-res image.
%
% See also: ROI_PREPROCESS_SUBJECTS

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $


spm_defaults
global defaults

if nargin<2,
    realign2mean = 0;
end;

defs          = defaults.realign;
V             = spm_vol(P);

if realign2mean,
    FlagsC        = struct('quality',defs.estimate.quality,'fwhm',5,'rtm',0);
else,
    FlagsC        = struct('quality',defs.estimate.quality,'fwhm',5);
end;

% No output argument, hence only the matfile is updated
spm_realign(V,FlagsC);

if realign2mean,
    FlagsR = struct('interp',defs.write.interp,...
        'wrap',defs.write.wrap,...
        'mask',defs.write.mask,...
        'which',2,'mean',1);

    % Create mean image only
    FlagsR.which = 0; FlagsR.mean = 1;
    spm_reslice(V,FlagsR);
end
