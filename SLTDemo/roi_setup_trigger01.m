function expt = roi_setup_trigger01(expt,sid)

if nargin<2 | isempty(sid),
    sid = [1:length(expt.subject)];
end;

roisess  = roisession;

for subjno=sid, %1:length(expt.subject),
    maskfile = spm_get('files',fileparts(expt.subject(subjno).structural.pp_affine),'wROImask*.img');
    for sessno=1:length(expt.subject(subjno).functional),
	roisess.mask = maskfile;
	roisess.validfiles = ...
	    expt.subject(subjno).functional(sessno).validfiles;
	roisess.realigntxt = ...
	    expt.subject(subjno).functional(sessno).realigntxt;
	roisess.onsets = ...
	    expt.subject(subjno).functional(sessno).onsets;
	roisess.durations = ...
	    expt.subject(subjno).functional(sessno).durations;
	roisess.covariates = ...
	    expt.subject(subjno).functional(sessno).covariates;
	expt.subject(subjno).roidata(sessno,1) = roisess;
    end;
end;

expt.design.roiSmoothFWHM = 12;

