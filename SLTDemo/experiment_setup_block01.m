function expt = experiment_setup_block01
% EXPT = EXPERIMENT_SETUP_TEMPLATE creates the experiment structure for use
% with ROITOOLBOX2 and SPM2B. You should modify this file to suit the needs
% of your experiment.

% This global variable informs the script about the structural
% organization of the data.

global dirTemplate
%%%% START MODIFY %%%%
dirTemplate.SubjDirPrefix = pwd;
dirTemplate.SubjDir = 'Subject.*';
dirTemplate.StructuralDirPrefix = '';
dirTemplate.StructuralDir = 'StructuralSeries.*';
dirTemplate.HiResDirPrefix = '';
dirTemplate.HiResDir = 'HiResFlashSeries.*';
dirTemplate.BoldDirPrefix = '';
dirTemplate.BoldDir = 'Series.*';
dirTemplate.Image = 'Subject*T*.img';
%%%% STOP MODIFY %%%%

% create new experiment object
expt            = experiment;

% set the basic fields
%%%% START MODIFY %%%%
expt.name       = 'Block experiment';
expt.startdate  = '9.19.2003';
expt.enddate    = 'Unknown';
expt.desc       = 'Block design demo';

expt.design     = design_setup_block01;    
expt.contrast   = contrast_setup_block01;

% Number of subjects
nSubjects       = 1;
%%%% STOP MODIFY %%%%

subj            = subject;
expt.subject    = subj(ones(nSubjects,1),:); % Creates a set of subjects


%%%% START MODIFY %%%%
% Create Experiment related info
% Session Series.* numbers per subject corresponding to valid runs
sessidx = {[5:9]};

% Boolean cell array indicating which of the Nruns*Ntrials were valid
validruns= {ones(5*Ntrials,1)};

% Run order for each subject
runorder = {[1:5]};

% Create subject information structure for each subject
for i=1:nSubjects,
    subjroot = fullfile(dirTemplate.SubjDirPrefix,sprintf('Subject.%02d',i));
    expt.subject(i) = subject_setup_block01(expt.subject(i),subjroot,sessidx{i},validruns{i},expt.design,i,runorder{i});
end;

