function expt = experiment_setup_trigger01
% EXPT = EXPERIMENT_SETUP_TEMPLATE creates the experiment structure for use
% with ROITOOLBOX2 and SPM2B. You should modify this file to suit the needs
% of your experiment.

global dirTemplate vol2analyze
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
dirTemplate.sapImage = 'Subject*.img';
%%%% STOP MODIFY %%%%

% create new experiment object
expt            = experiment;

% set the basic fields
%%%% START MODIFY %%%%
expt.name       = 'Triggered experiment';
expt.startdate  = '9.19.2003';
expt.enddate    = 'Unknown';
expt.desc       = 'Event triggered design demo';

expt.design     = design_setup_trigger01;    
expt.contrast   = contrast_setup_trigger01;

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

% Which trigger to analyze
% 0-both, 1-first, 2-second
vol2analyze     = 0;
if vol2analyze,
    expt.design.xBF_length = expt.design.xBF_length/2;
end

% Create subject information structure for each subject
for i=1:nSubjects,
    subjroot = fullfile(dirTemplate.SubjDirPrefix,sprintf(['%s%02d',strtok(dirTemplate.SubjDir,'*'),i));
    subjroot = fullfile(dirTemplate.SubjDirPrefix,sprintf('Subject.%02d',i));
    expt.subject(i) = subject_setup_trigger01(expt.subject(i),subjroot,sessidx{i},validruns{i},expt.design,i,runorder{i});
end;

