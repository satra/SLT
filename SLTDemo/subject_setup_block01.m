function subj = subject_setup_block01(subj,subjroot,sess,valid,dsgn,subjidx,runorder)
% SUBJ = SUBJECT_SETUP_TEMPLATE(SUBJ,SUBJROOT,SESS,VALID,DSGN) updates a
% subject entry in the experiment object with subject specific details with
% respect to the subject's sessions. You should modify this file to suit
% the needs of your experiment.

global dirTemplate vol2analyze

VPS = dsgn.volumespersession;

for n0 = 1:length(sess),
    dirn = fullfile(subjroot,dirTemplate.BoldDirPrefix,...
        sprintf('%s%03d',strtok(dirTemplate.BoldDir,'*'),sess(n0)));
    % get files in this directory
    filelist{n0} = spm_get('files', dirn, [dirTemplate.Image]);
end;
filelist = char(filelist);

numsessions = size(filelist,1)/VPS;
if numsessions~=length(sess),
    error(['SUBJECT_SETUP: Mismatch between number of sessions and' ...
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

% Define sesscov
sesscov = [];

for i=1:numsessions,
    funcsess(i).filenames   = filelist(VPS*(i-1)+[1:VPS],:);
    validsess = ones(size(funcsess(i).filenames,1),1);
    funcsess(i).validfiles  = validsess;
    funcsess(i).valid       = all(validsess);
    onsets = {};
    durations = {};
    if length(dsgn.blocklength)==1
	dsgn.blocklength = repmat(dsgn.blocklength,length(dsgn.condnames),1);
    end
    % runinfo can be a matrix per subject or a matrix per
    % experiment. 
    switch (dsgn.runinfotype),
     case 2,
      blockonsets = cumsum(dsgn.blocklength(runinfo(:,runorder(i))));
      blockonsets = blockonsets-blockonsets;
      for j=1:length(dsgn.condnames)
	  jidx = find(runinfo(:,runorder(i))==j);
	  onsets{j}    = blockduration(jidx);
	  durations{j} = dsgn.blocklength(j);
      end;
     case 1,
      blockonsets = cumsum(dsgn.blocklength(runinfo{subjidx}(:,i)));
      blockonsets = blockonsets-blockonsets;
      for j=1:length(dsgn.condnames)
	  jidx = find(runinfo{subjidx}(:,i)==j);
	  onsets{j}    = blockduration(jidx);
	  durations{j} = dsgn.blocklength(j);
      end;
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
