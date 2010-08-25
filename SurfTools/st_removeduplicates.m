function idx = st_removeduplicates(faces)
% IDX = ST_REMOVEDUPLICATES(FACES) removes duplicate faces from a
% triangular mesh which has its face normals oriented in a
% consistent manner. 
%
% See: ST_PREPROCESS

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

bDone = 0;
idx = [];
f1 = faces;
count = 0;

while ~bDone,
    % Create a set of all edges and find the unique edges. As a
    % side-effect of the function you can determine the non-unique
    % edges. 
    e = [f1(:,[1,2]);f1(:,[2,3]);f1(:,[3,1])];
    [B,I,J] = unique(e,'rows');

    % Find out which edges were duplicated. Since a consistent mesh
    % should not have two edges in the same order, this will
    % generate the inconsistencies list if present.
    idx1 = setdiff(J,I);

    if ~isempty(idx1),
	% Remove the face corresponding to the edge. This actually
        % will remove 3 edges from the next computation
	idx1 = mod(idx1-1,size(f1,1))+1
	f1(idx1(1),:) = -(f1(idx1(1),:)+count*0.001);
	idx = [idx;idx1(1)]
	count = count+1;
    else
	bDone = 1;
    end
end

