function roi_randfx_spmFigures(expt,contrasts,pvalue,imageDir,correction)
% function roi_randfx_spmFigures(expt,contrasts,pvalue,imageDir,correction)
% ROI_RANDFX_SPMFIGURES(EXPT) takes the information about the
% experiment and subjects embedded in the EXPT object and generates
% the figures from the estimated contrasts from the random fx analysis. 
%
% ROI_RANDFX_SPMFIGURES(...,CONTRASTS) allows one to specify which
% contrast figures are to be generated. 
%
% ROI_RANDFX_SPMFIGURES(...,PVALUE) allows one to specify the pvalue
% at which the contrast figures are to be generated.
%
% ROI_RANDFX_SPMFIGURES(...,IMAGEDIR) allows one to specify the
% directory in  which the contrast figures are to be generated.
%
% ROI_RANDFX_SPMFIGURES(...,PVALUE,...,CORRECTION) allows one to
% evaluate the contrasts using CORRECTION: {'none','FDR','FWE'}.
%
% See also: ROI_FMRI_DESIGN, ROI_ESTIMATE, ROI_CONTRAST

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Id: roi_randfx_spmFigures.m 120 2005-11-24 05:34:36Z satra $

% $NoKeywords: $

if nargin<2 | isempty(contrasts),
    contrasts = 1:length(expt.contrast);
end

if nargin<3 | isempty(pvalue),
    pvalue = 0.001;
end

if nargin<4 | isempty(imageDir),
    imageDir = 'contrasts01';
end
if nargin<5 | isempty(correction),
    correction = [];
end
spm_defaults;

if ~exist(imageDir,'dir'),
    mkdir(pwd,imageDir);
end
imageDir = fullfile(pwd,imageDir);

for i=contrasts(:)',
    subDirname = sprintf('Contrast.%04d',i)
    cd(subDirname);
    if exist(fullfile(pwd,'spm2.ps')),
	delete('spm2.ps');
    end
    validContrasts = zeros(length(expt.contrast),1);
    validContrasts(i)=-1;
    [pvalue] = roi_spmFigures(expt,validContrasts,pvalue,[],[],correction);
    
    d = dir([pwd filesep 'contrasts01' filesep '*.jpg']);
    movefile(fullfile(pwd,'contrasts01',d(1).name),imageDir);

    d = dir([pwd filesep '*.ps']);
    movefile(fullfile(pwd,d(1).name),fullfile(imageDir,sprintf('contrast%02d.ps',i)));

    d = dir([pwd filesep '*.txt']);
    movefile(fullfile(pwd,d(1).name),fullfile(imageDir,sprintf('contrast%02d.txt',i)));
    cd('..');
end

pdir = pwd;
if isempty(correction),
  correction = 'none';
end

cd(imageDir);
make_cmd = fileparts(which('roi_randfx_spmFigures'));
make_cmd = fullfile(make_cmd,'makepdf.sh');
significance = round(1000000*pvalue);
make_cmd1 = sprintf('%s RESULTS_rfx_p%06d_%s_%s',make_cmd,significance, ...
		   correction,date)
try
  system(make_cmd1);
catch
  fprintf('Could not make pdf');
end

make_cmd2 = sprintf(['cat contrast*.ps | ps2pdf14 - ' ...
                    'RESULTS_rfx_Labels_p%06d_%s_%s.pdf'],significance, ...
                   correction,date)  
try
  system(make_cmd2);
catch
  fprintf('Could not convert ps to pdf');
end

make_cmd3 = sprintf(['cat contrast*.txt > ' ...
                    'RESULTS_rfx_table_p%06d_%s_%s.txt'], ...
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

cd(pdir);
