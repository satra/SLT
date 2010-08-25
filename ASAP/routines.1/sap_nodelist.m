function [Nodes] = sap_nodelist;
%node_list
%creates structure containing node labels

% Series = {'Coronal Series' 'Axial Series' 'Lateral Sagittal Series'...
%       'Medial Sagittal Series'}; %4
% Nodes{1} = {'Plane A' 'Plane-I' 'Ins-Ant' 'Temp' 'Septum' 'BASFB'... 
%    	'Plane B' 'Plane J' 'Plane C' 'Plane M' 'Frt-Pos' 'He-Pos'...
%       'Plane D' 'Plane N' 'Splenium' 'Plane F' 'Plane G'}; %17
% Nodes{2} = {'SF-Prc' 'Plane K' 'Plane L' 'Poc-Hm' 'Poc_Inpar' 'IJ-Inpar'}; %6
% Nodes{3} = {'Plane A' 'Ahr-Syl' 'Aar-Syl' 'Aar-IF' 'IF-Prc' 'Plane O'...
%       'Ce-Syl' 'Plane P' 'Plane E'}; %9
% Nodes{4} = {'Plane H' 'Ci-Ant' 'Sp-Ci' 'Sp-Calc' 'CunPnt' 'Cun-PO'...
%       'Po-Hm'}; %7

% nodenum = [3 5 6 7 8 9 10 18 19 21 23 24 28 29 40 34 38 ...
%         17 22 25 30 26 32 ...
%         3 12 13 11 15 14 16 20 31 ...
%         2 4 27 33 35 36 37];

if exist('xlsread','file')>1,
    [ids,allnodes] = xlsread('nodelist.xls');
    numseries = size(allnodes,2)/3;
    allnodes = allnodes(2:end,[1:(numseries-1):end]);
else,
    error('xlsread does not exist');
    %[Sulci,id,Did] = textread('sulcilist.csv','%s%d%d','delimiter',',','headerlines',1);
end;

Series = {allnodes{1,:}};
allnodes = allnodes(2:end,:);
for i=1:numseries,
    Nodes(i).sername = Series{i};
    Nodes(i).sid = ids(1,3*(i-1)+1);
    Nodes(i).sdid = ids(1,3*(i-1)+2);
    
    Nodes(i).id = ids(2:end,3*(i-1)+1);
    Nodes(i).did = ids(2:end,3*(i-1)+2);
    idx = find(~isnan(Nodes(i).id));
    
    Nodes(i).id = Nodes(i).id(idx);
    Nodes(i).did = Nodes(i).did(idx);
    Nodes(i).names = {allnodes{idx,i}}';
    
    [sval,sid] = sort(Nodes(i).did);
    idx = find(sval);
    sid = sid(idx);
    Nodes(i).id = Nodes(i).id(sid);
    Nodes(i).did = 1:length(Nodes(i).id);
    Nodes(i).names = Nodes(i).names(sid);
end;
[sval,sid] = sort([Nodes.sdid]);
idx = find(sval);
sid = sid(idx);

Nodes = Nodes(sid);
