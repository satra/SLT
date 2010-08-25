idx=spm_ROI_input('private.AvailableRegions');
Labels=sap_getLabels;
Results=spm_ROI_read_stats(idx);
clear statsF statsP results;
for n1=1:length(Results.con),
   results{n1}=Results.con(n1).spatial.data.h;
   statsF{n1}=Results.con(n1).spatial.test.F;
   statsP{n1}=Results.con(n1).spatial.test.p;
end
results=cat(3,results{:});
statsF=cat(3,statsF{:});
statsP=cat(3,statsP{:});
Regions={Labels{idx}};
Contrasts=spm_ROI_input('model.ContrastName');
save('indi_results');
