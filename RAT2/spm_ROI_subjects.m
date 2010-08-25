function name=spm_ROI_subjects(sidx,exptfilename,spmfilename);

% SPM_ROI_SUBJECTS Selects subjects from EXPT structure
%
% spm_ROI_subjects(sidx,exptfilename) selects subjects sidx
% (vector of index to subjects) from the expt structure contained
% in the file exptfilename.
% spm_ROI_subjects([],exptfilename) selects all subjects
%
% alfnie@bu.edu
%
% $Id: spm_ROI_subjects.m 122 2005-11-29 08:39:13Z satra $

if nargin<3, spmfilename=[]; end
if ~ischar(exptfilename), exptfilename=exptfilename.filename; end
[pth,nm]=fileparts(exptfilename); %exptfilename=fullfile(pth,[nm,'.mat']);
load(exptfilename,'expt','-mat');
name=[expt.name,expt.desc]; name(name<'A'|name>'z'|(name>'Z'&name<'a'))=[]; nameroi=['roiproject_',name,'.roi']; nameexpt=['roiproject_',name,'.expt'];
nsubs=length(expt.subject);
if isempty(sidx), sidx=1:nsubs; end

% Selects subjects
expt.subject=expt.subject(sidx);
save(nameexpt,'expt','-mat');
if ~isempty(dir(nameroi)), spm_ROI_input('init','open',nameroi); else, spm_ROI_input('init','new',nameroi); end
spm_ROI_input('files.name_experiment',nameexpt);
for nsub=1:nsubs, cwd=['Subject.',num2str(nsub,'%03d')]; ok=mkdir(pwd,cwd); path_subject{nsub}=[pwd,filesep,cwd]; end; path_subject={path_subject{sidx}};
spm_ROI_input('files.path_subject',path_subject);

% Design matrix and contrasts
if isempty(spmfilename), roi_fMRI_design(expt,1:length(sidx),1); spmfilename='SPM.mat'; end
spm_ROI_input('model.DesignMatrix',[],spmfilename);
a=expt.contrast; b={a(:).c}'; c={a(:).name}';
X=spm_ROI_input('model.DesignMatrix');
nsess=spm_ROI_input('private.ValidSess');
Sess=spm_ROI_input('private.Sess');
SessOnes=spm_ROI_input('private.SessOnes');
spm2roidesign=spm_ROI_input('private.spm2roidesign');
d=cell(length(b),length(sidx)); 
cnsess=cumsum([0,nsess]);
checkerror=0;
for nsub=1:length(sidx), 
    %N=size(X{min(length(X),nsub)},2)/nsess(nsub)-1;
    %for ncon=1:length(b), d{ncon,nsub}=repmat([b{ncon},zeros(1,N-length(b{ncon}))],[1,nsess(nsub)]); end;    
    N={Sess(cnsess(nsub)+1:cnsess(nsub+1)).col};
    for ncon=1:length(b),
       d{ncon,nsub}=zeros(1,size(X{min(length(X),nsub)},2));
       if length(b{ncon})> length(N{1}), % if contrast defined for all sessions => direct map between spm design matrix and roi design matrix
           idx=find(spm2roidesign(nsub).spm<=length(b{ncon}));
           d{ncon,nsub}(spm2roidesign(nsub).roi(idx))=b{ncon}(spm2roidesign(nsub).spm(idx));
           b{ncon}(spm2roidesign(nsub).spm(idx))=0;
           if ~checkerror, disp('warning: in development - contrast covers more than one session'); checkerror=1; end
       else, % if contrast defined for a single session => repeat across sessions
           for nses=1:nsess(nsub), d{ncon,nsub}(N{nses}(1:length(b{ncon}))-N{1}(1)+1)=b{ncon}; end
       end
   end
end
if checkerror,
    for ncon=1:length(b),
        if any(abs(b{ncon})>0), disp(['warning: Columns numbers ',num2str(find(abs(b{ncon}(:))>0)'),' of the contrast #',num2str(ncon),' have been dropped']); end
    end
end
spm_ROI_input('model.ContrastVector',d);
spm_ROI_input('model.ContrastName',c);
spm_ROI_input('model.ContrastSpatialVector','1');

% 2nd-level Design matrix and contrasts
if ~isempty(expt.design.L2_X),
    spm_ROI_input('model.Level2DesignMatrix',expt.design.L2_X(sidx,:));
    spm_ROI_input('model.Level2ContrastVector',L2_contrast.c);
    spm_ROI_input('model.Level2ContrastName',L2_contrast.name);
else,
    spm_ROI_input('model.Level2DesignMatrix',ones(length(sidx),1));
    spm_ROI_input('model.Level2ContrastVector',{1});
    spm_ROI_input('model.Level2ContrastName',{'selected subjects'});
end

% model parameters
spm_ROI_input('model.RepetitionTime',expt.design.TR);
spm_ROI_input('model.MaxPeriod',expt.design.xX_K_HParam);
if isempty(strmatch('xX_K_LParam',fieldnames(expt.design))), 
   %%%~isfield(expt.design,'xX_K_LParam'), 
   spm_ROI_input('model.MinPeriod',2*expt.design.TR); else, spm_ROI_input('model.MinPeriod',expt.design.xX_K_LParam); end
spm_ROI_input('model.Whitening',expt.design.whitening);
spm_ROI_input('model.DataReductionType',expt.design.dataReductionType);
spm_ROI_input('model.DataReductionLevel',expt.design.dataReductionLevel);
if isempty(strmatch('RemoveGlobal',fieldnames(expt.design))),
  %~isfield(expt.design,'RemoveGlobal'), 
  spm_ROI_input('model.RemoveGlobal',0); else, spm_ROI_input('model.RemoveGlobal',expt.design.RemoveGlobal); end

