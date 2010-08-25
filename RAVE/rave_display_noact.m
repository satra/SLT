function rave_display_noact
% RAVE_DISPLAY_NOACT  Displays the surface only with possible roi
% boundaries

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /RAVE/rave_display_noact.m 1     12/13/02 5:48p Satra $

% $NoKeywords: $

% Load the surface information
load(rave_input('surf_file'));

% Extract appropriate fields from the data
surf = fv(rave_input('surf_id'));
clear fv;

% Define the vertex data to be the color of sulci
vdata = 3*ones(prod(size(surf.vertices))/3,1);

% If curvature information is present load it
if rave_input('show_curvature'),
    vdata = mc{rave_input('surf_id')};
end;

% Check and set border vertices if required
if rave_input('show_roiborders'),
    vdata = rave_checksetborders(ROIpatch,vdata);
end;

rave_displaysurf(surf,vdata,rave_input('internal_cmap'));