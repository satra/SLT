function subj = subject_setup_trigger01(subj,subjroot,sess,valid,dsgn,subjid,runorder)
% SUBJ = SUBJECT_SETUP_TEMPLATE(SUBJ,SUBJROOT,SESS,VALID,DSGN) updates a
% subject entry in the experiment object with subject specific details with
% respect to the subject's sessions. You should modify this file to suit
% the needs of your experiment.

global dirTemplate vol2analyze

VPT  = dsgn.volumespertrigger;
VPS  = dsgn.volumespersession;
EVPS = VPS/VPT;


for n0 = 1:length(sess),
    dirn = fullfile(subjroot,dirTemplate.BoldDirPrefix,...
        sprintf('%s%03d',strtok(dirTemplate.BoldDir,'*'),sess(n0)));
    % get files in this directory
    filelist{n0} = spm_get('files', dirn, [dirTemplate.Image]);
end;
filelist = char(filelist);

numsessions = size(filelist,1)/VPS;
if numsessions~=length(sess),
    warning(['SUBJECT_SETUP: Mismatch between number of sessions and' ...
	   ' volumes per session']);
end

load(dsgn.runinfo,'runinfo');

% Create objects for each session type
structsess  = session;
hiressess   = session;
funcsess    = session;

StructDir = dir([fullfile(subjroot,dirTemplate.StructDirPrefix,dirTemplate.StructuralDir)]);
StructDir = StructDir(1).name;
structsess.filenames = spm_get('files',fullfile(subjroot,StructDir),[dirTemplate.sapImage]);

HiResDir = dir([fullfile(subjroot,dirTemplate.HiResDirPrefix,dirTemplate.HiResDir)]);
HiResDir = HiResDir(1).name;
hiressess.filenames = spm_get('files',fullfile(subjroot,HiResDir),[dirTemplate.Image]);

funcsess = funcsess(ones(numsessions,1),:);

% Setup session specific regressors
voldiff = [ones(1,EVPS);repmat(-ones(1,EVPS),VPT-1,1)]; 

% Accounts for difference between successive volumes
if ~vol2analyze
    sesscov = [voldiff(:)];
else,
    sesscov = [];
end;

for i=1:numsessions,
    funcsess(i).filenames   = filelist(VPS*(i-1)+[1:VPS],:);
    validsess = valid((EVPS)*(i-1)+[1:EVPS]);
    validsess = validsess(:,ones(1,VPT))';
    validsess = validsess(:);
    if vol2analyze,
	validsess(:) = 0;
	validsess(vol2analyze:2:end) = 1;
    end
    funcsess(i).validfiles  = validsess;
    funcsess(i).valid       = all(valid(EVPS*(i-1)+[1:EVPS]));

    onsets = {};
    durations = {};
    % runinfo can be a matrix per subject or a matrix per
    % experiment. 
    switch (dsgn.runinfotype),
     case 2,
      for j=1:length(dsgn.condnames)
	  if vol2analyze,
	      onsets{j} = (VPT*(find(runinfo(:,runorder(i))==j))-VPT)/VPT;
	  else,
	      onsets{j} = (VPT*(find(runinfo(:,runorder(i))==j))-VPT);
	  end;
	  durations{j} = 0;
      end
     case 1,
      for j=1:length(dsgn.condnames)
	  if vol2analyze,
	      onsets{j} = (VPT*(find(runinfo{subjidx}(:,runorder(i))==j))-VPT)/VPT;
	  else,
	      onsets{j} = (VPT*(find(runinfo{subjidx}(:,runorder(i))==j))-VPT);
	  end;
	  durations{j} = 0;
      end
     otherwise,
      error('SUBJECT_SETUP: unknown dsgn.runinfotype');
    end      
    funcsess(i).onsets       = onsets;
    funcsess(i).durations    = durations;
    funcsess(i).covariates   = sesscov; 
end

% Assign the information to the subject 
subj.structural = structsess;
subj.hires      = hiressess;
subj.functional = funcsess;
