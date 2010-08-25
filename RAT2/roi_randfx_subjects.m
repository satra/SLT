function roi_randfx_subjects(expt,sid,doFlag,pvalue,L1_contrast_list)
% ROI_RANDFX_SUBJECTS(EXPT) performs a mixed effects analyses on
% the subjects defined in the EXPT structure. It first runs a fixed
% effects analysis on each subject and then combines the results at
% a second level.
%
% ROI_RANDFX_SUBJECTS(EXPT,SID) allows one to specify which
% subjects' should be considered as part of the analysis. An empty
% value of SID performs the steps on all the subjects.
%
% ROI_RANDFX_SUBJECTS(EXPT,SID,DOFLAG) controls which steps of the
% process to perform. DOFLAG is a string input that takes the
% following options: 'all'[default], 'design', 'estimate',
% 'contrast', 'figures'.   
%
% ROI_RANDFX_SUBJECTS(EXPT,SID,DOFLAG) controls which steps of the
% process to perform. DOFLAG is a string input that takes the
% following options: 'all'[default], 'design', 'estimate',
% 'contrast', 'figures', 'level1'.   
%
% ROI_RANDFX_SUBJECTS(...,PVALUE) allows one to specify the pvalue
% at which the contrast figures are to be generated. Only affects
% flags, doAll and figures.
%
% ROI_RANDFX_SUBJECTS(...,PVALUE,L1_CONTRAST_LIST) allows one to
% evaluate only the contrasts indexed by L1_CONTRAST_LIST
%
% See also: ROI_FIXEDFX_SUBJECTS, ROI_COMBINE_CONTRASTS, ROI_SPMFIGURES

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Changes 17.Jan.2004
% [Satra] Added generation of figures automatically after
% analysis. The figures are generated on subject specific brains.
% [Jay 28.Oct.2004] Added doflag option 'level1' to only perform the level 1 
% analysis for the subjects specified.  i.e. will not run roi_combine_contrasts

if nargin<3 | isempty(doFlag),
    doFlag = 'all';
end;
if nargin<2 | isempty(sid),
    sid = 1:length(expt.subject);
end;
if nargin<4,
    pvalue = [];
end
if nargin<5,
    L1_contrast_list = [];
end

spm_defaults;

roi_write_log('roi_randfx_subjects: Start');
if ~strcmp(doFlag,'l2contrast'),
    for i=sid(:)',
	roi_write_log(['roi_randfx_subjects: Start Subject',num2str(i)]);
	dirname = sprintf('Subject.%02d.Results',i);
	st =  mkdir(dirname);
	cd(dirname);

	% Generate figure on subject specific brain image.
	[path,nm] = ...
	    fileparts(expt.subject(i).structural(1).pp_full);
	templatefile = fullfile(path,['render_',nm,'_seg1.mat']);
	switch doFlag,
	 case {'all','level1'}
	  roi_fMRI_design(expt,i);
	  roi_estimate('SPM.mat');
	  roi_contrast(expt,i,'SPM.mat',L1_contrast_list);
	  try
	      roi_spmFigures(expt,[],pvalue,0,templatefile);
	  catch
	      roi_write_log(sprintf('Could not generate figures for subject: %2d',i));
	  end
	 case 'design',
	  roi_fMRI_design(expt,i);
	 case 'estimate',
	  roi_estimate('SPM.mat');
	 case 'contrast',
	  roi_contrast(expt,i,'SPM.mat',L1_contrast_list);
	 case 'figures',
	  try
	      roi_spmFigures(expt,[],pvalue,0,templatefile);
	  catch
	      roi_write_log(sprintf('Could not generate figures for subject: %2d',i));
	  end
	 otherwise,
	  error('Unknown option.');
	end;
	cd('..');
    end;
end;

if strcmp(doFlag,'l2contrast') | strcmp(doFlag,'all'),
    % Combine the contrasts from each subject
    roi_combine_contrasts(expt,sid,L1_contrast_list);
end 
