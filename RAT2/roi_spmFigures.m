function [pvalue] = roi_spmFigures(varargin)

% This function creates and saves spm style figures for each contrast
% you've specified.  
% Inputs: 
% =========================================================================
% usage: roi_spmFigures(expt,[valid],pvalue)
% expt : The expt object for your study (i.e. RAT2 processing stream)
%
% valid : Optional argument, a vector of length length(expt.contrasts) 
%         specifying which ontrasts to draw and save (i.e. a one in
%         valid(n) to draw contrast n.  If not specified, draw ALL contrast
%         images!
% pvalue: This is the pvalue you can threshold your images at. You
%         can either set a global pvalue or you can set a pvalue
%         per contrast.
% tabulate: A boolean flag specifying whether or not to tabulate values.
% template: Rendering template see template under Description
% 
% Below are the defaults for figure generation.  If you change these here,
% they will be set in each spmParams struct.  You can override these for
% each individual contrast figure below.
% Description:
% ========================================================================
% pAdj :        p value error correction (none, 'FWE' family wise error
%               correction, 'FDR' false discovery rate)
% pThresh :     cutoff for significant voxels (SPM defaults to 0.05 for
%               error corrected (FWE|FDR), 0.001 for none.
% xThresh :     extent threshold (minimum # voxels in a cluster)
% brighten :    controls aesthetics of rendered 'blobs'.  Use NaN for spm96
%               style yellow/red blobs, 1 for red blobs (no brightening) 
%               down to 0 for a lot of brightening of red blobs.
% template :    which brain template to render on.  Choose 'spm96' for old 
%               spm brain including medial surface, 'smooth' for a smoothed
%               average brain, 'single' for a typical single brain.
% tabulate :    1 to create and save summary tables of active clusters, 0 
%               for no tables (just brain images)
% subdir   :    name of a directory in the cwd you wish to create and place
%               the figures in.  Can not override this per contrast!
% filename :    Do not enter a default here.  The default is to trim out
%               white spaces from your contrast name, and prefix with
%               'cImg_' (contrast image).  You can override this in each
%               individual contrast if you like, but be careful!

if ((length(varargin) < 1) | (length(varargin) > 6)), 
    fprintf('Usage: roi_spmFigures(expt,[valid],pvalue,tabulate,template,pAdj)');
    help(mfilename);
    return;
end;

expt = varargin(1);
expt = expt{1};

if nargin<2 | isempty(varargin{2}),
    valid = ones(length(expt.contrast),1);
else,
    valid = varargin(2);
    valid = valid{1};
end;

if nargin<3 | isempty(varargin{3}),
    pvalue = 0.001;
else,
    pvalue = varargin{3};
end

if prod(size(pvalue))==1,
    pvalue = pvalue(ones(size(valid)),:);
end
    
if nargin<4 | isempty(varargin{4}),
    tabulate = 0;
else,
    tabulate = varargin{4};
end
if nargin<5 | isempty(varargin{5}),
    template = 'spm96';        
else,
    template = varargin{5};        
end

if nargin<6 | isempty(varargin{6}),
    pAdj = 'none';        
else,
    pAdj = varargin{6};        
end

% Explained in header above
figDefaults.pAdj = pAdj;             
figDefaults.pThresh = pvalue;  %0.05
figDefaults.xThresh = 0; 
figDefaults.brighten = 1; %0.75          
figDefaults.template = template;
figDefaults.subdir = 'contrasts01';
figDefaults.tabulate = tabulate;              

exptContrasts = expt.contrast;        

% Create the subdirectory if its not there
if (~isdir(figDefaults.subdir)),
    fprintf('Creating subdirectory %s',figDefaults.subdir);
    mkdir(figDefaults.subdir);
end;

count = 1;
for i=1:length(exptContrasts),
    if (valid(i) == 1),
	realChars = isletter(expt.contrast(i).name);
        thisFilename = [pwd filesep figDefaults.subdir filesep 'cImg' sprintf('%02d',i) '-' deblank(expt.contrast(i).name(realChars))];
        spmParams(count) = struct('Ic',i,'pAdj',figDefaults.pAdj,'pThresh',figDefaults.pThresh(i), ...
                           'xThresh',figDefaults.xThresh,'brighten',figDefaults.brighten, ...
                           'template',figDefaults.template,'tabulate',figDefaults.tabulate, ...
                           'filename',thisFilename);
        count = count + 1;
    elseif (valid(i) < 0)
	realChars = isletter(expt.contrast(i).name);
        % If i is -1, this is being collected from random fx analysis.
        thisFilename = [pwd filesep figDefaults.subdir filesep 'cImg' sprintf('%02d',i) '-' deblank(expt.contrast(i).name(realChars))];
        spmParams(count) = struct('Ic',1,'pAdj',figDefaults.pAdj,'pThresh',figDefaults.pThresh(i), ...
                           'xThresh',figDefaults.xThresh,'brighten',figDefaults.brighten, ...
                           'template',figDefaults.template,'tabulate',figDefaults.tabulate, ...
                           'filename',thisFilename);
        count = count + 1;
    end;
end;

% Down here you can override any of the defaults for a particular contrast
% if you would like to.  For example,
% spmParams(3).pThresh = 0.075; would change the threshold for only the
% third contrast

%spmParams(1).tabulate = 1;

roi_drawall_contrasts('setup',spmParams);       % does the work

close all;

% [SG] return the maximum pvalue to be attached to the filename
pvalue = max(pvalue);
