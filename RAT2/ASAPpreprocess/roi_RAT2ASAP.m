function expt = roi_RAT2ASAP(expt,sid,FLAGS)
% EXPT = ROI_RAT2ASAP(EXPT) takes the affine normalized structural
% image information for each subject stored in the EXPT object and
% preprocesses it for use with ASAP.  
%
% ROI_RAT2ASAP(EXPT,SID) specifies which subjects' to preprocess
% for ASAP using a vector SID. If left empty all subjects are
% processed.  
%
% ROI_RAT2ASAP(EXPT,SID,FLAGS) controls the two steps of this
% routine. Currently FLAGS is a 3 element boolean vector:
% [doPreprocess, doCreateMask, doForceMask]. The first flag
% converts the data into an ASAP project file. The second step
% takes an ASAP project file and converts it to an ROImask. The
% third option forces a recreation of the maskfile even if it does
% exist. 
%
% See also: ROI_ASAP_PREPROCESS, SAP_COMMAND

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Initialize SPM
spm_defaults;

% Initialize ASAP
sap_command('initialize');

if nargin<2 | isempty(sid),
    sid = [1:length(expt.subject)];
end
if nargin<3,
    FLAGS = [0 0 0];
end

doPreprocess = 1 & FLAGS(1);
doCreateMask = 1 & FLAGS(2);
doForceMask  = 1 & FLAGS(3);

% prepare subject directories for working with freesurfer
for i=sid,
    normalized_image = deblank(expt.subject(i).structural.pp_affine);

    % Process the structural and create ASAP project file
    if doPreprocess
	sptfile = roi_asap_preprocess(normalized_image,1);
	expt.subject(i).ASAPspt = sptfile;
    end
    if isempty(expt.subject(i).ASAPspt),
	expt.subject(i).ASAPspt = spm_get('Files',fileparts(normalized_image),'mwSubject*.spt'); 
    end

    sptfile = expt.subject(i).ASAPspt; 

    % Convert the edited ASAP project file into an ROImask
    % Edit the template with the value in sap_createROImask.m
    maskfile = spm_get('Files',fileparts(normalized_image),'wROImask*.img'); 
    if (doCreateMask & ~isempty(sptfile) & isempty(maskfile)) | doForceMask,
	maskfile = sap_command('createmask',sptfile,normalized_image);
    end
    expt.subject(i).ASAPmask = maskfile;
end
