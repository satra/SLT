function label = roi_annot2label(annot,map)
% LABEL = ROI_ANNOT2LABEL(ANNOT,MAP) converts the annotation pRGB
% values ANNOT to PUids based on the PUid-->pRGB mapping provided
% in MAP. 
%
% See also: ROI_FS2RAT

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

label = zeros(size(annot));

for i=1:size(map,1),
    idx = find(annot == map(i,2));
    if ~isempty(idx),
	label(idx) = map(i,1);
    end;
end;
