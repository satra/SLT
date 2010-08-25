function sap_changenames(braindatafile)
% SAP_AUTOSEG An attempt at automatic segmentation of brain given ...
%   braindatafile: actual volume data
%   brainmaskfile: underestimated mask generated by SPM

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/preprocess.1/sap_autoseg.m 2     10/08/02 2:37p Satra $

% $NoKeywords: $

% Setup globals
global DEBUG


[pth,nm,xt] = fileparts(braindatafile);
suffix = [nm,'_'];

brainmaskfile   = [suffix,'brainmask.mat'];
brainmaskfile2  = [suffix,'brainmask2.mat'];
wmmaskfile      = [suffix,'wmmask.mat'];
extmaskfile     = [suffix,'extmask.mat'];
cortexfile      = [suffix,'cortex.mat'];
otlfile         = [suffix,'otl.mat'];
surffile        = [suffix,'brainsurf.mat'];
leftsurffile    = [suffix,'leftsurf.mat'];
rightsurffile   = [suffix,'rightsurf.mat'];


str = sprintf('ren %s %s',[pth,filesep,'brainmask.mat'],brainmaskfile);
dos(str);
str = sprintf('ren %s %s',[pth,filesep,'brainmask2.mat'],brainmaskfile2);
dos(str);
str = sprintf('ren %s %s',[pth,filesep,'wmmask.mat'],wmmaskfile);
dos(str);
str = sprintf('ren %s %s',[pth,filesep,'extmask.mat'],extmaskfile);
dos(str);
str = sprintf('ren %s %s',[pth,filesep,'cortex.mat'],cortexfile);
dos(str);
str = sprintf('ren %s %s',[pth,filesep,'otl.mat'],otlfile);
dos(str);
str = sprintf('ren %s %s',[pth,filesep,'brainsurf.mat'],surffile);
dos(str);
str = sprintf('ren %s %s',[pth,filesep,'leftsurf.mat'],leftsurffile);
dos(str);
str = sprintf('ren %s %s',[pth,filesep,'rightsurf.mat'],rightsurffile);
dos(str);
