function spm_ROI_bch_run(opts);
% spm_ROI_bch_run 
% Run spm_ROI processing steps (model estimation only)
%

% 03/02
% alfnie@bu.edu

hmsgbox=msgbox('Model estimation and Hypotheses testing ...','spm_ROI processing status', 'replace'); drawnow;
spm_ROI_model;
if ishandle(hmsgbox), close(hmsgbox); end

hmsgbox=msgbox('Done!','spm_ROI processing status', 'replace'); drawnow;
