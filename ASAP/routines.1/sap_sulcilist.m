function [Sulci,id] = sap_sulcilist;
%pst_sulcilist

%Series = {'Coronal Series' 'Dorsal Axial Series' 'Lateral Sagittal Series'...
%     'Medial Sagittal Series' 'Ventral Axial Series'}; %4
% Sulci = {'aar_syl' 'ahr_syl' 'angular' 'calcarine' 'central' 'cent_insula' 'cingulate' ... 
%    'circular' 'collateral' 'cuneal' 'first_trans' 'Heschls' 'inf_frontal' 'inf_temporal' ...
%    'intraparietal' 'Jensens' 'lat_occipital' 'occ_temporal' 'olfactory' ...
%    'par_occipital' 'par_syl' 'paracingulate' 'phr_syl' 'post_central' ...
%    'precentral' 'subparietal' 'sup_frontal' 'sup_temporal' }; %28

if exist('xlsread','file')>1,
    [idpairs,Sulci] = xlsread('sulcilist.xls');
    Sulci = Sulci(2:end,1);
    id    = idpairs(:,1);
    Did   = idpairs(:,2);
else,
    [Sulci,id,Did] = textread('sulcilist.csv','%s%d%d','delimiter',',','headerlines',1);
end;

Sulci = deblank(Sulci);

% Remove all elements that are not displayed
[sval,sid] = sort(Did);
idx = find(sval);
sid = sid(idx);

% Sort displayed names by display id
Sulci = Sulci(sid);
id    = id(sid);
Did   = 1:length(Did(sid));
