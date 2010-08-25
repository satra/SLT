function [Labels,labelid] = roi_load_labels
% [LABELS,LABELID] = ROI_LOAD_LABELS returns the LABELS and their
% corresponding numerical identifiers (LABELID). The labels are
% loaded from the excel file. This function returns all labels
% defined in the excel file not just what is displayed in ASAP.  
%
% See also: ROI_LABEL2ID 

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

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
labelid = [id;32000+id];
Labels = Labels(labelid);
Labels = Labels(:);
