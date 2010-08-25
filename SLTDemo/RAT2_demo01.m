% Step 1. Initialize Matlab paths
RAT2_start

% Step 2. Change to working directory
cd(?experiment working directory?);

% Step 3. Create experiment object
ABCD = experiment_setup_ABCD; 
save ABCD;

% Step 4. Preprocess subjects
ABCD = roi_preprocess_subjects(ABCD); 
save ABCD;
if adding_subject,
    roi_preprocess_subjects(ABCD,length(ABCD.subject));
    ABCD = roi_preprocess_subjects(ABCD,[],’both’,[0 0 0 0 0]);
    save ABCD;
end

% Step 5,6,7,8. ASAP_processing 
ASAP_start
roi_RAT2ASAP(ABCD);
%Perform ASAP edits
roi_RAT2ASAP(ABCD,[],[0 1]);

% Step 9,10,11,12 FreeSurfer_processing
freesurfer_start
roi_RAT2FS(ABCD,’ABCD’,[],[1 1 1 0 0 0 0 0]);
% Perform FreeSurfer edits
roi_RAT2FS(ABCD,’ABCD’,[],[0 0 0 1 1 1 1 1]);

% Step 13,14,15. ROI preprocessing
% Modify roi_setup_ABCD if needed.
ABCD = roi_setup_ABCD(ABCD); save ABCD;
ABCD = roi_create_ROI_data(ABCD); save ABCD;
if adding_subject,
    roi_create_ROI_data(ABCD,length(ABCD.subject));
    ABCD = roi_create_ROIdata(ABCD,[],[0 0]);
    save ABCD;
end

% Step 16,17,18 SPM2 analysis
mkdir(‘ABCD.spm2’);cd(‘ABCD.spm2’);
roi_fixedfx_subjects(ABCD);
roi_spmFigures(ABCD);

% Step 19,20,21,22,23,24 ROI analyses
mkdir(‘ABCD.roi’);cd(‘ABCD.roi’);
spm_ROI_subjects([],’ABCD_filename’);
spm_ROI_model;
results = spm_ROI_results;
mkdir(‘ABCD.figures’);cd(‘ABCD.figures’);
roi_Fig_create(results);

