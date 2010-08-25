function roi_combine_contrasts(expt,sid,contrast_list)
% ROI_COMBINE_CONTRASTS(EXPT,SID) performs a one smaple t-test on
% all the con*.img files generated by the first level analysis for
% all the subjects and each contrast specified in the EXPT object.
%
% ROI_COMBINE_CONTRASTS(EXPT,SID) allows one to specify which
% subjects' should be considered as part of the analysis. An empty
% value of SID performs the steps on all the subjects.
%
% ROI_COMBINE_CONTRASTS(...,CONTRAST_LIST) allows one to specify
% which contrasts to combine as indexed by CONTRAST_LIST.
%
% [TODO] Modify this file to include other covariates of interest
% such as behavioral data. Seems like it just involves modifying
% the xX.X matrix and the contrast vectors.
%
% See also: ROI_RANDFX_SUBJECTS

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Id: roi_combine_contrasts.m 126 2005-12-13 20:30:44Z satra $

% $NoKeywords: $

spm_defaults;

pdir = pwd;

if nargin<2 | isempty(sid),
    sid = 1:length(expt.subject);
end;

if nargin<3 | isempty(contrast_list),
    contrast_list = 1:length(expt.contrast),
end
contrast_list = contrast_list(:)';

% Retrieve contrast images
for i=sid(:)',
    dirname = sprintf('Subject.%02d.Results',i);
    conimages{find(sid==i),1}=spm_get('Files',fullfile(pdir, ...
						  dirname),'con*.img');
    conimages{find(sid==i),1} = conimages{find(sid==i),1}(1:length(expt.contrast),:);
end

% reorganize the images such that they are a set per contrast
% across subjects
[M,N] = size(conimages{1,1});
conimages = permute(reshape(char(conimages)',N,M,length(sid)),[3 1 2]);

% evaulate a t-stat for each contrasts across the list of subjects
% Need to create a separate directory for each contrast as the
% SPM.mat file is utilized later for evaluating results.
for i=contrast_list,
    condir = sprintf('Contrast.%04d',i);
    if isdir(fullfile(pdir,condir)),
	cd(condir);
	delete('*.*');
    else,
	mkdir(condir);
	cd(condir);
    end
    
    %for j=sid(:)'
    %	imgs{find(sid==j),1} = conimages{j}(i,:);
    %end
    
    N = length(sid);

    % Create SPM structure (see spm_spm_ui.m for details)
    xY.P  = squeeze(conimages(:,:,i));
    xY.VY = spm_vol(xY.P);

    xX.X  = ones(N,1);
    xX.I  = ones(N,4);
    xX.I(1:end,1) = 1:N;
    xX.iH = 1;
    xX.iC = zeros(1,0);
    xX.iB = zeros(1,0);
    xX.iG = zeros(1,0);
    xX.name = {'mean'};
    xX.sF = {'obs' '' '' ''};

    xC = [];

    xGX.iGXcalc = 1;
    xGX.iGXcalc = 'omit';
    xGX.rg      = []; 
    xGX.iGMsca  = 9;
    xGX.sGMsca  = '<no grand Mean scaling>';
    xGX.GM      = 0;
    xGX.gSF     = zeros(N,1);
    xGX.iGC     = 12;
    xGX.sGC     = '(redundant: not doing AnCova)';
    xGX.iGloNorm= 9;
    xGX.sGloNorm= '<no global normalisation>';

    xVi.iid = 1;
    xVi.V   = speye(N);

    xM.T = -Inf;
    xM.TH= -Inf*ones(N,1);
    xM.I = 1;
    xM.VM= [];
    xM.xs.Analysis_threshold = 'None (-Inf)';
    xM.xs.Implicit_masking   = 'Yes: NaN''s treated as missing';
    xM.xs.Explicit_masking   = 'No';

    xsDes.Design               = 'One sample t-test';
    xsDes.Global_calculation   = 'omit';
    xsDes.Grand_mean_scaling   = '<no grand Mean scaling>';
    xsDes.Global_normalisation = '<no global normalisation>';
    xsDes.Parameters={'1 condition, +0 covariate, +0 block, +0 nuisance';...
    '1 total, having 1 degrees of freedom';...
    sprintf('leaving %d degrees of freedom from %d images',N-1,N)};

    SPMid = 'RAT2: Combine contrasts';

    % Create the SPM structure
    SPM = [];
    SPM.xY          = xY;                   % filenames/mapped data
    SPM.nscan       = size(xX.X,1);         % scan number
    SPM.xX          = xX;                   % design structure
    SPM.xC          = xC;                   % covariate structure
    SPM.xGX         = xGX;                  % global structure
    SPM.xVi         = xVi;                  % non-sphericity structure
    SPM.xM          = xM;                   % mask structure
    SPM.xsDes       = xsDes;                % description
    SPM.SPMid       = SPMid;                % version

    % End create SPM structure

    save SPM SPM;

    %Evaluate statistics
    spm_spm('SPM.mat');

    %Create level-2 contrast
    load SPM;
    c           = [1];
    cname       = expt.contrast(i).name;
    stat        = 'T';
    SPM.xCon    = spm_FcUtil('Set',cname,stat,'c',c(:),SPM.xX.xKXs);
    save SPM;

    % Evaluate 2nd-level contrast
    spm_contrasts('SPM.mat');

    cd(pdir);
end


%     % initialize design configuration structure
%     % One could potentially generate the SPM.mat file and then just
%     % change the filenames for each contrast evaluation.
%     D = spm_spm_ui('DesDefs_Stats');
%     D = D(1);
%     D.iGMsca = 9;
%     D.iGXcalc = 1;
%     D.M_.X = 0;
%     D.myP = imgs;
%     D.myI = ones(size(imgs,1),4);
%     D.myI(1:end,1) = 1:size(imgs,1);

%     % Create SPM.mat file
%     spm_spm_ui('CFG',D);
