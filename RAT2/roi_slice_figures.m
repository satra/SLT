function roi_slice_figures(expt,sid,randfx)

basedir = '..';
if nargin<2 | isempty(sid),
    sid = [1:length(expt.subject)];
else,
    sid = sid(:)';
end
if nargin<3 | isempty(randfx),
    randfx = 0;
end

maxval = 2  %max effect size 
maskfile = fullfile(basedir,sprintf('spmT_%04d.img',3));
sig1 = 1e-2;
sig2 = 1e-3; %0.5*1e-4;
maxval = [];

if randfx,
    basedir2 = basedir;
end
if ~randfx,
    sid = 1;
end
%mkdir slicefigures;
for subj=sid
    if randfx,
	basedir = fullfile(basedir2,sprintf('Subject.%02d.Results', ...
					   subj));
	rendfile = deblank(expt.subject(subj).structural(1).pp_full);
	maskfile = fullfile(basedir,sprintf('spmT_%04d.img',5));
    end
    for n0=3, %1:2:length(expt.contrast),
	if randfx,
	    maskfile = fullfile(basedir,sprintf('spmT_%04d.img', ...
						n0));
	    sig1 = 0.01;
	end
	Fig_handle = spm_figure('GetWin','Graphics');
	spm_figure('Clear',Fig_handle);
	text(0,1,['Contrast name: ',expt.contrast(n0).name]);
	set(gca,'visible','off');
	spm_print;
	for d0=2, %1:3,
	    try
	    if randfx,
	    split2_display(fullfile(basedir,sprintf('con_%04d.img', ...
						    n0)),sig2, ...
			   d0,0,3,maxval,rendfile,maskfile,sig1);

	    else,
	    split2_display(fullfile(basedir,sprintf('con_%04d.img', ...
						    n0)),sig2, ...
			   d0,0,3,maxval,[],maskfile,sig1);
	    end
	    catch
		spm_figure('Clear',Fig_handle);
		text(0,1,['Error:',lasterr]);
		set(gca,'visible','off');
	    end		
	    spm_print;
	end
    end
    if randfx & 0,
	subjfile = sprintf('Subject_%02d.ps',subj);
	movefile('spm2.ps',subjfile);
	cmd = ['ps2pdf14 ',subjfile];
	unix(cmd);
	delete(subjfile);
    end
end
