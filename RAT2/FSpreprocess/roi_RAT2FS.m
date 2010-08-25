function maskfile = roi_RAT2FS(expt,prefix,sid,FLAGS)
% MASKFILE = ROI_RATFS(EXPT,PREFIX) takes the structural image
% information for each subject stored in the EXPT object and
% creates a FreeSurfer directory prefixed by the provided PREFIX as
% (PREFIX.NN). The process starts with converting the structural
% image into FreeSurfer format and ends with converting a
% classified FreeSurfer surface into volume mask whose filename is
% returned in MASKFILE. The first two arguments are compulsory.
% 
% ROI_RAT2FS(EXPT,PREFIX,SID) specifies which subjects' to process
% in FreeSurfer using a vector SID. If left empty all subjects are
% processed. 
%
% ROI_RAT2FS(EXPT,PREFIX,SID,FLAGS) provides a finer grained
% control on every step of the process. Currently FLAGS is an 9
% element boolean vector: [doCreateDir, doConvertImg, doPreprocess,
% doCreateSurf, doStage3, doStage4a, doStage4b, doClassify,
% doFS2RAT]. Each flag is described below.
%
% doCreateDir  = Creates freesurfer subject directory
% doConvertImg = Convert Analyze image to FreeSurfer .COR format 
% doPreprocess = pre-manual  editing (mc, tal, norm, strip, seg, stage2)
% doCreateSurf = with manual editing (fill, tess, sm1, inf1)
% doStage3     = runs the topology fixer (and stage2)
% doStage4a    = make final surfaces
% doStage4b    = spherical morph
% doClassify   = auto-classifier
% doFS2RAT     = convert surface back to mask
%
% See also: ROI_FS2RAT

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Initialize SPM
spm_defaults;

SUBJECTS_DIR = getenv('SUBJECTS_DIR');
SLT_DIR = fileparts(which(mfilename));
SLT_dir = fullfile(SLT_DIR,'..','..')
if isempty(SUBJECTS_DIR),
    error('FreeSurfer Environment not set');
end;
if nargin<2,
    error('prefix required. not provided');
end
if nargin<3 | isempty(sid),
    sid = [1:length(expt.subject)];
end
if nargin<4,
    FLAGS = [1 1 1 1 1 1 1 1 1];
end

if length(FLAGS)<9,
    error('roi_RAT2FS: Flag length should be 9. New flags have been added');
end

% For a description of stages: recon-all --help
doCreateDir  = 1 & FLAGS(1);   % Creates freesurfer subject directory
doConvertImg = 1 & FLAGS(2);   % 
doPreprocess = 1 & FLAGS(3);   % pre-manual  editing (mc, tal,
                               % norm, strip, seg, stage2)
doCreateSurf = 1 & FLAGS(4);   % with manual editing (fill, tess,
                               % sm1, inf1)
doStage3     = 1 & FLAGS(5);   % runs the topology fixer (and stage2)
doStage4a    = 1 & FLAGS(6);   % make final surfaces
doStage4b    = 1 & FLAGS(7);   % spherical morph
doClassify   = 1 & FLAGS(8);   % autoparc classifier
doFS2RAT     = 1 & FLAGS(9);   % convert surface back to mask

pdir = pwd;

tic;
cd(SUBJECTS_DIR);
% prepare subject directories for working with freesurfer
for i=sid,
    % create a new directory structure by copying the template
    % SUBJDIRTEMPLATE
    subjfsdir = sprintf('%s.%02d',prefix,i);
    if doCreateDir,
	if ~exist(fullfile(SUBJECTS_DIR,subjfsdir),'dir'),
%	    unix(sprintf('%s/FSParc/roi_createdir %s',SLT_dir,subjfsdir)); 
	    unix(sprintf('mksubjdirs  %s',subjfsdir)); 
	end;
    end;

    if doConvertImg,
	% Create a mat file for the structural file
	structfile = deblank(expt.subject(i).structural.pp_affine);
	V = spm_vol(structfile);
	[pth,nm,xt] = fileparts(structfile);
	M = V.mat;
	save(fullfile(pth,[nm,'.mat']),'M','-V4','-MAT');
	
	% Convert the structural file to COR format 
	unix(sprintf('%s/FSParc/roi_convert_img2cor %s %s',SLT_dir,structfile,subjfsdir));
    end;
    
    if doPreprocess,
	% Run preprocessing
	unix(sprintf(['recon-all -subjid %s -stage1 ' ...
		      ' -notalairach -wsatlas'],subjfsdir));
%	unix(sprintf(['recon-all -subjid %s -stage1 -nonuintensitycor' ...
%	      ' -notalairach -wsatlas'],subjfsdir));
    end;

    if doCreateSurf,
	% Run preprocessing
	unix(sprintf('recon-all -subjid %s -stage2 -wsatlas',subjfsdir));
    end;

    % Run postprocessing
    if doStage3,
	unix(sprintf('recon-all -subjid %s -stage3',subjfsdir));
    end;

    if doStage4a,
	unix(sprintf('recon-all -subjid %s -stage4a',subjfsdir));
    end;

    if doStage4b,
	unix(sprintf('recon-all -subjid %s -stage4b -hemi rh -nomorphrgb',subjfsdir));
	unix(sprintf('recon-all -subjid %s -stage4b -hemi lh -nomorphrgb',subjfsdir));
    end
    if doClassify,
	unix(sprintf('./FSParc/roi_classify  %s',subjfsdir));
    end;

    if doFS2RAT,
	%unix(sprintf('recon-all -subjid %s -stage4a',subjfsdir));
	structfile = deblank(expt.subject(i).structural.pp_affine);
	maskfile{i,1} = roi_FS2RAT(subjfsdir,structfile);
    end
end
cd(pdir);
toc;
