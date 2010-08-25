function roi_contrast(expt,sid,SPMmatfile,contrast_list)
% ROI_CONTRAST(EXPT,SPMMATFILE) evaluates the contrasts as designed
% in the EXPT structure. It does so by updating the relevant fields
% of the SPM structure and then calling spm_contrasts on the
% updated structure.
% 
% ROI_CONTRAST(...,CONTRAST_LIST) evaluates only the contrasts
% indexed by CONTRAST_LIST
%
% See also: CONTRAST_SETUP_DEMO, ROI_FIXEDFX_SUBJECTS,
% ROI_FMRI_DESIGN, ROI_ESTIMATE, ROI_RANDFX_SUBJECTS 

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

if isempty(sid),
  sid = 1:length(expt.subject);
end

if nargin<4,
    contrast_list = [];
end;
contrast_list = contrast_list(:)';

load(SPMmatfile);

% F-contrasts
%---------------------------------------------------------------------------
numc = size(SPM.xX.X,2);
nsess= length(SPM.nscan);
try
    oldxCon = SPM.xCon;
    if exist('SPMfields.mat','file'),
	save('SPMfields.mat','oldxCon','-APPEND');
    else,
	save('SPMfields.mat','oldxCon');
    end;
    clear oldxCon
    
    SPM.xCon = SPM.xCon(1);
catch,
end
numcovariates = size(SPM.Sess(1).C.C,2);

try
  beta = randn(numc,1);
  Y = SPM.xX.X*beta;
  beta_hat = pinv(SPM.xX.X)*Y;
catch
  warning('Could not invert design matrix');
end

for i=1:length(expt.contrast)
  if isfield(expt.contrast(i),'asis') & expt.contrast(i).asis,
    c = expt.contrast(i).c(:)';
  else
    c = repmat([expt.contrast(i).c(:)',zeros(1,numcovariates)],1,nsess);
  end
  c = [c,zeros(1,numc-length(c))];
  c = c/length(sid);
  if exist('beta_hat')
    y = c*[beta_hat,beta];
    if abs(y(1)- y(2))>.0001,
      error(['improper contrast definition: ', num2str(i)]);
    end
  end
  cname       = expt.contrast(i).name
  stat        = expt.contrast(i).stat;
  SPM.xCon(i) = spm_FcUtil('Set',cname,stat,'c',c(:),SPM.xX.xKXs);
  fprintf('Setting contrast [%d]\n',i);
end;

try
  xVi = SPM.xVi;
  save('SPMwxVi.mat','SPM');
  SPM = rmfield(SPM,'xVi');
  if exist('SPMfields.mat','file'),
    save('SPMfields.mat','xVi','-APPEND');
  else,
    save('SPMfields.mat','xVi');
  end;
  clear xVi;
catch
  disp('xVi non existent');
end;

save(SPMmatfile,'SPM');
clear SPM

% Evaluate
%---------------------------------------------------------------------------
if ~isempty(contrast_list),
  spm_contrasts(SPMmatfile,contrast_list);
else,
  spm_contrasts(SPMmatfile);
end
