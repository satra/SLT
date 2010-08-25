function roi_fixedfx_subjects(expt,sid,doFlag,pvalue,contrast_list,correction)
% ROI_FIXEDFX_SUBJECTS(EXPT) is a wrapper around SPM that takes the
% information about the experiment and subjects embedded in the
% EXPT object and performs 3 operations: SPM fMRI design creation,
% model estimation and contrast evaluation.
%
% ROI_FIXEDFX_SUBJECTS(EXPT,SID) allows one to specify which
% subjects' should be considered as part of the analysis. An empty
% value of SID performs the steps on all the subjects.
%
% ROI_FIXEDFX_SUBJECTS(EXPT,SID,DOFLAG) controls which steps of the
% process to perform. DOFLAG is a string input that takes the
% following options: 'all'[default], 'design', 'estimate',
% 'contrast','figures'.   
%
% ROI_FIXEDFX_SUBJECTS(...,PVALUE) allows one to specify the pvalue
% at which the contrast figures are to be generated. Only affects
% flags, doAll and figures.
%
% ROI_FIXEDFX_SUBJECTS(...,PVALUE,CONTRAST_LIST) allows one to
% evaluate only the contrasts indexed by CONTRAST_LIST.
%
% ROI_FIXEDFX_SUBJECTS(...,PVALUE,...,CORRECTION) allows one to
% evaluate the contrasts using CORRECTION: {'none','FDR','FWE'}.
%
% See also: ROI_FMRI_DESIGN, ROI_ESTIMATE, ROI_CONTRAST

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Id: roi_fixedfx_subjects.m 120 2005-11-24 05:34:36Z satra $

% $NoKeywords: $

if nargin<2,
    sid = [];
end;
if nargin<3 | isempty(doFlag),
    doFlag = 'all';
end;
if nargin<4 | isempty(pvalue),
    pvalue = [];
end
if nargin<5 | isempty(contrast_list),
    contrast_list = [];
end
if nargin<6 | isempty(correction),
    correction = [];
end
spm_defaults;

switch doFlag,
case 'all',
 roi_fMRI_design(expt,sid);
 roi_estimate('SPM.mat');
 roi_contrast(expt,sid,'SPM.mat');
 roi_fixedfx_subjects(expt,sid,'figures',pvalue);
case 'design',
 roi_fMRI_design(expt,sid);
case 'estimate',
 roi_estimate('SPM.mat');
case 'contrast',
 roi_contrast(expt,sid,'SPM.mat',contrast_list);
case 'figures',
 [pvalue] = roi_spmFigures(expt,[],pvalue,[],[],correction);
 if isempty(correction),
   correction = 'uncorrected';
 end
 imageDir = 'contrasts01';

 d = dir([pwd filesep '*.ps']);
 if ~isempty(d);
   movefile(fullfile(pwd,d(1).name),fullfile(imageDir,'contrasts_all.ps'));
 end

 d = dir([pwd filesep 'Atlas*.txt']);
 if ~isempty(d)
   movefile(fullfile(pwd,d(1).name),imageDir);
 end

 pdir = pwd;

 cd(imageDir);
 make_cmd = fileparts(which(mfilename));
 make_cmd = fullfile(make_cmd,'makepdf.sh');
 significance = round(1000000*pvalue);
 make_cmd1 = sprintf('%s RESULTS_ffx_p%06d_%s_%s',make_cmd,significance, ...
		   correction,date)
 try
   system(make_cmd1);
 catch
   fprintf('Could not make pdf');
 end
 
 make_cmd2 = sprintf('ps2pdf14 contrast*.ps RESULTS_ffx_Labels_p%06d_%s_%s.pdf',significance,correction,date)
 try
   system(make_cmd2);
 catch
   fprintf('Could not convert ps to pdf');
 end

 make_cmd3 = sprintf('cat Atlas*.txt > RESULTS_ffx_table_p%03d_%s_%s.txt', ...
                    significance,correction,date)
 try
   system(make_cmd3);
 catch
   fprintf('Could not append text');
 end
 fid = fopen('make_cmd.csh','wt');
 fprintf(fid,'#!/bin/tcsh -ef\n');
 fprintf(fid,'%s\n',make_cmd1);
 fprintf(fid,'%s\n',make_cmd2);
 fprintf(fid,'%s\n',make_cmd3);
 fclose(fid);
 system('chmod 755 make_cmd.csh');
 %system('./make_cmd.csh');
 cd(pdir);
 otherwise,
 error('Unknown option.');
end;

