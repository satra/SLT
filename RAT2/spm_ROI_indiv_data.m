function results = spm_ROI_indiv_data(expt)
%create data structure of individual ROI data in 
% format similar to group data, i.e., results
% listed in alpabetical order according to region,
% F,p, and effect sizes (h), provided along with
% region and contrast labels.
%
% must be in roi data directory

[all_labels,all_valid]=sap_getLabels;
all_labels = all_labels(all_valid)'; %get complete list of ROI labels

[Results,valid]=spm_ROI_read_stats(all_valid); 	% compile study-specific stats
						% including study-specific regions

results.name = [expt.name,'individual ROI results'];
results.regions = all_labels(valid);% regions in study in same order as data
 
for i = 1:length(expt.contrast)
	results.contrasts{i}=expt.contrast(i).name;
	results.F(:,:,i)=Results.con(i).spatial.test.F;
	results.p(:,:,i)=Results.con(i).spatial.test.p;
	results.h(:,:,i)=Results.con(i).spatial.data.h;
end;

%sort to put data/regions in alphabetical order w.r.t. regions

[results.regions,I]= sort(results.regions);
results.F=results.F(I,:,:);
results.p=results.p(I,:,:);
results.h=results.h(I,:,:);
