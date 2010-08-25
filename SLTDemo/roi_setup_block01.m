function expt = roi_setup_ripple01(expt)

roisess  = roisession;
maskfile = spm_get('files',fileparts(expt.subject(1).structural.pp_affine),'SURF2RAT*.img')

for subjno=1:length(expt.subject),
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

