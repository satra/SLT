function sap_projfile = sap_preprocess_single(T1_filename)
% SAP_PREPROCESS_SINGLE Processes a single T1 image to generate data needed
% for ASAP interaction.
%       T1_filename: T1 weighted image to process

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/preprocess.1/sap_autoseg.m 2     10/08/02 2:37p Satra $

% $NoKeywords: $

% Setup globals
global DEBUG


% Step 1. Perform affine normalization
hmsgbox=msgbox('Affine Normalization ...','Preprocessing status', 'replace'); drawnow;
sap_normalize(spm_vol(T1_filename));
if ishandle(hmsgbox), close(hmsgbox); end
[pth,nm,xt,vr] = fileparts(deblank(T1_filename));    
normimage = [pth filesep 'n' nm xt];

% Step 2. Extract brain mask
hmsgbox=msgbox('Segmentation ...','Preprocessing status', 'replace'); drawnow;
sap_gensegmask(normimage);
if ishandle(hmsgbox), close(hmsgbox); end
corrimage = [pth filesep 'corr_n' nm xt];

% Step 3. Refine brain mask
[pth,nm,xt,vr] = fileparts(deblank(corrimage));    
%disp(sprintf('Int Cmd: pdir=pwd;cd(''%s'');sap_autoseg(''%s'',1);cd(pdir);',pth,[nm xt]));

hmsgbox=msgbox('BrainMask Extraction ...','Preprocessing status', 'replace'); drawnow;
sap_autoseg(corrimage);
if ishandle(hmsgbox), close(hmsgbox); end

% Step 4. Create an ASAP project file
sap_projfile = sap_createproj(corrimage);
hmsgbox=msgbox('Done ...','Preprocessing status', 'replace'); drawnow;
pause(3);
if ishandle(hmsgbox), close(hmsgbox); end
