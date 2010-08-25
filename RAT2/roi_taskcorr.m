function [t_series regressor_sh] = roi_taskcorr(expt,labels,runinfo);
% ROI_TASKCORR
% Gathers the ROI time series data from subject data specified in
%   expt for each ROI in cell array of ROI labels. 
% Voxel data is averaged within each ROI, average response for a
%  a session is subtracted from the ROI time series within a
%  session, sessions are then concatenated. 
% Jason Tourville 9/13/05

%get the label id's but keep the id/label correspondence around
[l,i] = roi_load_labels;
for n1=1:length(labels),
    idx = strmatch(labels{n1},l,'exact');
    if ~isempty(idx),
	id(n1) = i(idx);
    else	
	id(n1) = NaN;
    end;
end
IDs=length(id);
for sub = 1:length(expt.subject),
  allsh_data = [];
  allnosh_data = [];
  bigZsh = [];
  bigRsh = [];
  bigZnosh = [];
  bigRnosh = [];
  for sess = 1:length(expt.subject(sub).roidata),
    data_sh = [];
    data_nosh = [];
    for roi = 1:IDs,
      idx=find(expt.subject(sub).roidata(sess).PUlist==id(roi));
      load(deblank(expt.subject(sub).roidata(sess).data(idx,:)));
      t_series.label{sess,roi,sub}=xY.name;
      roi_mean=mean(xY.y,2);
      overall_mean=mean(roi_mean);
      adj_mean=roi_mean-overall_mean;
      sh=find(runinfo{sub}(:,sess)==3)'; %get the shifted
                                         %trials...make sure is
                                         %correct (check expt.design)
      sh=[sh*2-1;sh*2];sh=sh(:);
      nosh=find(runinfo{sub}(:,sess)==2)';%get the unshifted
                                          %trials...make sure is
                                          %correct (check expt.design)
      nosh=[nosh*2-1;nosh*2];nosh=nosh(:);
      sh_mean=adj_mean(sh);
      nosh_mean=adj_mean(nosh);
      
      %regressors for shift data
      Nsh=length(sh_mean);
      regressor_sh = ones(Nsh,1);
      regressor_sh(2:2:Nsh)=-1;
      regressor_sh = [regressor_sh linspace(0,1,Nsh)' ...
                      cos(pi*(0:Nsh-1)'*(1:8)/Nsh)];
      regress_sh=sh_mean-regressor_sh*(pinv(regressor_sh)*sh_mean);
      data_sh=[data_sh regress_sh];
      %regressors for noshift data
      Nnosh=length(nosh_mean);
      regressor_nosh = ones(Nnosh,1);
      regressor_nosh(2:2:Nnosh)=-1;
      regressor_nosh = [regressor_nosh linspace(0,1,Nnosh)' ...
                      cos(pi*(0:Nnosh-1)'*(0:8)/Nnosh)];
      regress_nosh=nosh_mean-regressor_nosh*(pinv(regressor_nosh)*nosh_mean);
      data_nosh=[data_nosh regress_nosh];
    end;
    %get the correlations (and standardized correlations) within a
    %session for both the shift and unshifted trials and
    %concatenated them
    Rsh=corrcoef(data_sh);
    Zsh=atanh(Rsh); 
    bigZsh(:,:,sess)=Zsh;  
    bigRsh(:,:,sess)=Rsh;
    %allsh_data=[allsh_data;data_nosh];
    Rnosh=corrcoef(data_nosh);
    Znosh=atanh(Rnosh); 
    bigZnosh(:,:,sess)=Znosh;  
    bigRnosh(:,:,sess)=Rnosh;
    %allnosh_data=[allsh_data;data_nosh];
    %but we are actually interested in the differences
    Rdiff=Rsh-Rnosh;
    Zdiff=atanh(Rdiff);
    bigZdiff(:,:,sess)=Zdiff;
    bigRdiff(:,:,sess)=Rdiff;
  end
  %shift data
  %t_series.datash{sub}=allsh_data;
  t_series.Zsh{sub}=bigZsh;
  t_series.Rsh{sub}=bigRsh;
  t_series.meanZsh_Sub(:,:,sub)=mean(bigZsh,3);
  %noshift data
  %t_series.datanosh{sub}=allnosh_data;
  t_series.Znosh{sub}=bigZnosh;
  t_series.Rnosh{sub}=bigRnosh;
  t_series.meanZnosh_Sub(:,:,sub)=mean(bigZnosh,3);
  t_series.Zdiff{sub}=bigZdiff;
  t_series.Rdiff{sub}=bigRdiff;
  t_series.meanZdiff_Sub(:,:,sub)=(round(mean(bigZdiff,3)*1e4))/1e4;
end
vecZ=shiftdim(t_series.meanZdiff_Sub,2);
[H,p,CI]=ttest(vecZ);
t_series.p=shiftdim(p,1);
t_series.CI=shiftdim(CI,1);
t_series.overallZdiff=mean(t_series.meanZdiff_Sub,3);
t_series.overallZsh=mean(t_series.meanZsh_Sub,3);
t_series.overallZnosh=mean(t_series.meanZnosh_Sub,3);
figure;
imagesc(real(tanh(t_series.overallZdiff)));colorbar;
labels = t_series.label(1,:,1); 
set(gca,'ytick',[1:IDs],'yticklabel',labels);
xtick=[1:IDs];xticklabels=labels;
xticklabel_rotate90(xtick,xticklabels);
title('Region Correlation Differences by Task');
figure;
f=find(t_series.p<=.05);
p=zeros(size(t_series.p));
p(f)=t_series.p(f);
imagesc(p);colorbar;
set(gca,'ytick',[1:IDs],'yticklabel',labels);
xticklabel_rotate90(xtick,xticklabels);
title('Significantly Different Correlations');

%t_series_avgR=tanh(t_series.meanZ);

%t_series.meanZ=mean(t_series.meanZ_Sub,3);
%vecZ=shiftdim(t_series.meanZ_Sub,2);

