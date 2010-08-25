function t_series=roi_timeseries_x_trig(expt,labels)

% ROI_TIMESERIES
% Gathers the ROI time series data from subject data specified in
%   expt for each ROI in cell array of ROI labels. 
% Voxel data is averaged within an each ROI, average response for a
%  a session is subtracted from the ROI time series within a
%  session, sessions are then concatenated. 
% In this version, the triggers are isolated and treated as
%  separate runs.
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
  allroi_data_first=[];
  allroi_data_second=[];
  for roi = 1:length(id),
    data_first=[];
    data_second=[];
    for sess = 1:length(expt.subject(sub).roidata),
      idx=find(expt.subject(sub).roidata(sess).PUlist==id(roi));
      load(deblank(expt.subject(sub).roidata(sess).data(idx,:)));
      t_series.label{sess,roi,sub}=xY.name;
      roi_mean=mean(xY.y,2);
      %separate the triggers
      m=mod(1:length(roi_mean),2);
      roi_mean_first=roi_mean(find(m));
      roi_mean_second=roi_mean(find(m==0));
      overall_mean_first=mean(roi_mean_first);
      overall_mean_second=mean(roi_mean_second);
      adj_mean_first=roi_mean_first-overall_mean_first;
      adj_mean_second=roi_mean_second-overall_mean_second;
      data_first=[data_first;adj_mean_first];
      data_second=[data_second;adj_mean_second];
    end
    allroi_data_first=[allroi_data_first data_first];
    allroi_data_second=[allroi_data_second data_second];
  end
  [R_first,p_first]=corrcoef(allroi_data_first);
  t_series.data_first{sub}=allroi_data_first;
  t_series.R_first{sub}=R_first;
  t_series.Rp_first{sub}=p_first;
  [R_second,p_second]=corrcoef(allroi_data_second);
  t_series.data_second{sub}=allroi_data_second;
  t_series.R_second{sub}=R_second;
  t_series.Rp_second{sub}=p_second;
end

