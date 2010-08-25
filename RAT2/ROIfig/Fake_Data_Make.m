function results = Fake_Data_Make(hemi)
% Creates a results data structure containing the ROIids and 
% "state" of "active" ROIs in the HEMI hemisphere.


[Nums,txt raw] = xlsread('PUlist_fig.xls');
if strmatch(hemi,'left'),
    Fx = Nums(:,2);    
elseif strmatch(hemi,'right'),
    Fx = Nums(:,3);
else 
    error('Which hemisphere are you planning to plot?');
end
idx = find(Fx);
results.ROIids=Nums(idx,1);
results.Fx=Fx(idx);

 