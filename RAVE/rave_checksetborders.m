function vdata = rave_checksetborders(ROIpatch,vdata)

% If we are asked to show the borders of ROIs, determine which borders to
% show. Then extract the vertices of the structure constituting those
% borders and set their color to black
ROIstruct = ROIpatch{rave_input('surf_id')};
clear ROIpatch;

didx = rave_input('roi_displayid');
if all(didx>0),
    ridx = [ROIstruct(:).id]';
    [c,idx] = intersect(ridx,didx);
    if ~isempty(c),
        % Extract all the border vertices belonging to the ROIs to be
        % displayed and set it to 1
        ROIstruct = ROIstruct(idx);
    else,
        ROIstruct = [];
    end;
end
N = length(ROIstruct);
if N>0,
    [X{1:N}] = deal(ROIstruct.bvert);
    vertlist = cell2mat(X');
    vdata(vertlist) = 1;
end;
