function [t_series regressor] = roi_timeseries(expt,labels);
% ROI_TIMESERIES
% Gathers the ROI time series data from subject data specified in
%   expt for each ROI in cell array of ROI labels. 
% Voxel data is averaged within an each ROI, average response for a
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

for sub = 1:length(expt.subject),
  allroi_data=[];
  bigZ=[];
  bigR=[];
  for sess = 1:length(expt.subject(sub).roidata),
    data = [];
    for roi = 1: length(id),
      idx=find(expt.subject(sub).roidata(sess).PUlist==id(roi));
      load(deblank(expt.subject(sub).roidata(sess).data(idx,:)));
      t_series.label{sess,roi,sub}=xY.name;
      roi_mean=mean(xY.y,2);
      overall_mean=mean(roi_mean);
      adj_mean=roi_mean-overall_mean;
      %regress out differing trigger responses
      N=length(adj_mean);
      regressor = ones(N,1);
      regressor(2:2:N)=-1;
      regressor = [regressor linspace(0,1,N)' cos(pi*(0:N-1)'*(0:8)/N)];
      %figure;hist(regressor);
      adj_mean_regress=adj_mean-regressor*(pinv(regressor)*adj_mean);
      %figure;plot(adj_mean,'r');hold on; plot(adj_mean_regress,'.');
      data=[data adj_mean_regress];
    end;
    R=corrcoef(data);
    Z=atanh(R); 
    bigZ(:,:,sess)=Z;  
    bigR(:,:,sess)=R;
    allroi_data=[allroi_data;data];
  end
  t_series.data{sub}=allroi_data;
  t_series.Z{sub}=bigZ;
  t_series.R{sub}=bigR;
  t_series.meanZ_Sub(:,:,sub)=mean(bigZ,3);
end
t_series.meanZ=mean(t_series.meanZ_Sub,3);
vecZ=shiftdim(t_series.meanZ_Sub,2);
[H,p,CI]=ttest(vecZ);
t_series_p=shiftdim(p,1);
t_series_CI=shiftdim(CI,1);
t_series_avgR=tanh(t_series.meanZ);
