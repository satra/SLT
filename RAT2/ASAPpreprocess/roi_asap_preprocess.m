function sap_projfile = roi_asap_preprocess(T1_filename,normalized_flag)
% ROI_ASAP_PREPROCESS Processes a single T1 image to generate data needed
% for ASAP interaction.
%       T1_filename: T1 weighted image to process
%   normalized_flag: Indicates whether the T1 volume is the result
%                    of affine normalization [default 0]

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/preprocess.1/sap_autoseg.m 2     10/08/02 2:37p Satra $

% $NoKeywords: $

% Setup globals
global DEBUG

if nargin<2,
    normalized_flag = 0;
end

% Step 1. Perform affine normalization
hmsgbox=msgbox('Affine Normalization ...','Preprocessing status', 'replace'); drawnow;
if normalized_flag,
    [pth,nm,xt,vr] = fileparts(deblank(T1_filename));
else,
    roi_affinenormalize_subject(T1_filename);
    [pth,nm,xt,vr] = fileparts(deblank(T1_filename));
    nm = ['w' nm];
end
if isempty(pth),
    pth = pwd;
end
normimage = [pth filesep nm xt];
if ishandle(hmsgbox), close(hmsgbox); end
    
% Step 2. Extract brain mask
hmsgbox=msgbox('Segmentation ...','Preprocessing status', 'replace'); drawnow;
roi_genbrainmask(normimage);
if ishandle(hmsgbox), close(hmsgbox); end
corrimage = [pth filesep 'm' nm xt];

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
