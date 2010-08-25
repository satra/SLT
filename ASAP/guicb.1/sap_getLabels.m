function [Labels,valid] = sap_getLabels

if exist('xlsread','file')>1,
    [idpairs,PU] = xlsread('PUlist.xls');
    PU = PU(2:end,1);
    id    = idpairs(:,1);
    Did   = idpairs(:,2);
else,
    [PU,id,Did] = textread('PUlist.csv','%s%d%d','delimiter',',','headerlines',1);
end;

PU = deblank(PU);

[Labels{1:32000+max(id)}]=deal('');
for i=1:length(PU),
    Labels{id(i)} = strcat('Right',PU{i});
    Labels{32000+id(i)} = strcat('Left',PU{i});
end;
valid = [id;32000+id];
