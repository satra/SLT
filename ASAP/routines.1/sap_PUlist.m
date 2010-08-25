% Parcellation Unit List
function [PU,id] = sap_PUlist;

% PU= {'Gray' 'White' 'None' 'AG' 'CALC' 'CGa' 'CGp' 'CN' 'CO' 'F1' 'F2' 'F3o' ...
%       'F3t' 'FMC' 'FO' 'FOC' 'FP' 'H' 'aINS' 'pINS' 'JPL' 'LG' 'OF' ... 
%       'OLi' 'OLs' 'OP' 'PAC' 'PCN' 'PHa' 'PHp' 'PO' 'POG' 'PP' ...
%       'PRG' 'PT' 'SC' 'SCLC' 'SGa' 'SGp' 'SPL' 'T1a' 'T2a' ...
%       'T3a' 'T1p' 'T2p' 'T3p' 'TFa' 'TFp' 'TO2' 'TO3' 'TOF' ...
%       'TP' 'CGPC' 'BASFB'}; %49

if exist('xlsread','file')>1,
    [idpairs,PU] = xlsread('PUlist.xls');
    PU = PU(2:end,1);
    id    = idpairs(:,1);
    Did   = idpairs(:,2);
else,
    [PU,id,Did] = textread('PUlist.csv','%s%d%d','delimiter',',','headerlines',1);
end;

PU = deblank(PU);

% Remove all elements that are not displayed
[sval,sid] = sort(Did);
idx = find(sval);
sid = sid(idx);

% Sort displayed names by display id
PU = PU(sid);
id    = id(sid);
Did   = 1:length(Did(sid));
