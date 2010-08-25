function id = roi_label2id(labels)
% ID = ROI_LABEL2ID(LABELS) provides a vector id  corresponding to
% the labels given as input. The values in id are picked up from
% the Excel spreadsheet PUlist.xls subject to the condition 
%               left_id = 32000+right_id
%
% See also: ROI_LOAD_LABELS

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

[l,i] = roi_load_labels;

for n1=1:length(labels),
    idx = strmatch(labels{n1},l,'exact');
    if ~isempty(idx),
	id(n1) = i(idx);
    else	
	id(n1) = NaN;
    end;
end
