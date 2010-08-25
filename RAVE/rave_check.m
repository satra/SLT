function valid = rave_check
%RAVE_CHECK Checks to ensure that all information is available before
%   displaying
%   
%   See also RAVE_DEFAULTS, RAVE_INPUT

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /RAVE/rave_check.m 1     12/13/02 5:47p Satra $

% $NoKeywords: $

% Check that surface file exists
valid = 0;

% Surface file is a necessary requirement
if ~rave_filecheck('surf_file'),
    disp('rave_check: [surf_file] does not exist');
    return;
end;

% TODO: Replace with rave_checksurffile since a lot of things need to checked
s = whos('-file',rave_input('surf_file'));
varnames = cellstr(strvcat(s(:).name));
rave_input('surf_hasidx',~isempty(find(strcmp(varnames,'idx'))));
rave_input('surf_hascurvature',~isempty(find(strcmp(varnames,'mc'))));
rave_input('surf_haspatch',~isempty(find(strcmp(varnames,'ROIpatch'))));

rave_input('show_curvature',rave_input('show_curvature')& rave_input('surf_hascurvature'));
rave_input('show_roiborders',(all(rave_input('roi_displayid')~=0)) & rave_input('show_roiborders')& rave_input('surf_haspatch'));

% Check if each of the following files exist and 
% set the corresponding flag
rave_filecheck('roi_label','has_roilabel');
rave_filecheck('structural_img','has_structural');
rave_filecheck('contrast_timg','has_tcontrast');
rave_filecheck('contrast_pimg','has_pcontrast');
rave_filecheck('roi_actimg','has_roivol');

rave_input('has_roiact',~isempty(rave_input('roi_act')));

if isempty(intersect(1:max(s(find(strcmp(varnames,'fv'))).size),rave_input('surf_id'))),
    disp('rave_check: Surface identifier does not exist');
    return;
end;
rave_input('has_altid',~isempty(intersect(1:max(s(find(strcmp(varnames,'fv'))).size),rave_input('surf_altid'))));

if rave_input('show_act')~=0,
    if ~rave_filecheck('colormap_file'),
        disp('rave_check: Colormap file does not exist');
        return;
    end;
end;

% Make sure all conditions are satisfied for each type of display
% 0 [none]  Don't display any activity
% 1 [standard]  Use whole volume info instead of ROI activity
% 2 [uniform]   All vertices for an ROI have the same activity
% 3 [center]    Activity spreads out from centerpos
% 4 [sphere]    Activity at centerpos, color/radius of sphere
switch rave_input('show_act'),
    case 0,
    case 1,
        if ~rave_input('has_altid'),
            disp('rave_check: convoluted surface does not exist');
            return;
        end;
        switch rave_input('use_vol'),
            case 1,
                if ~rave_input('has_tcontrast'),
                    disp('rave_check: tcontrast does not exist');
                    return;
                end;
            case 2,
                if ~rave_input('has_pcontrast'),
                    disp('rave_check: pcontrast does not exist');
                    return;
                end;
            case 3,
                if ~rave_input('has_roivol'),
                    disp('rave_check: roi_vol does not exist');
                    return;
                end;
            case -1,
                if ~rave_input('has_tcontrast'),
                    disp('rave_check: tcontrast does not exist');
                    return;
                end;
                if ~rave_input('has_pcontrast'),
                    disp('rave_check: pcontrast does not exist');
                    return;
                end;
            otherwise,
	     return;
        end;
    case {2,3,4},
        if ~rave_input('surf_haspatch'),
            disp('rave_check: No patches for the surface');
            return;
        end;
        if rave_input('use_roivol'),
            if ~rave_input('has_roivol'),
                disp('rave_check: roi_vol does not exist');
                return;
            end;
        else,
            if ~rave_input('has_roiact'),
                disp('rave_check: roi_act does not exist');
                return;
            end;
        end;
    otherwise,
end;

% All checks passed
valid = 1;

function valid = rave_filecheck(filename,flagname)
valid = 0;
eval(sprintf('%s= rave_input(''%s'');',filename,filename));
if isempty(eval(filename)) | ~exist(eval(filename),'file'),
    if nargin==2,
        rave_input(flagname,0);
    end;
else,
    if nargin==2,
        rave_input(flagname,1);
    end;
    valid = 1;
end;
