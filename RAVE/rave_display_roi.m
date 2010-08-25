function rave_display_roi(display_type)
% RAVE_DISPLAY_STANDARD Displays a volume of activation on the provided
% surface

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /RAVE/rave_display_roi.m 1     12/13/02 5:48p Satra $

% $NoKeywords: $

% Load the surface information
load(rave_input('surf_file'));

% Extract appropriate fields from the data
surf = fv(rave_input('surf_id'));

% The alternate surface describes the original convoluted surface from
% which an inflated surface was made. This information will possibly be put
% in the surface mat file or the voxel indices.
surf_alt = fv(rave_input('surf_altid'));
clear fv;

if length(surf.vertices) ~= length(surf_alt.vertices),
    disp('rave_display_uniform: the two surfaces are not similar');
    return;
end;

% Define the vertex data to be the color of sulci
vdata = 3*ones(prod(size(surf.vertices))/3,1);

% If curvature information is present load it
if rave_input('show_curvature'),
    vdata = mc{rave_input('surf_id')};
end;

% Read in the data to be displayed
if rave_input('use_roivol'),
    V = spm_vol(rave_input('roi_actimg'));
    Y = spm_read_vols(V);
    % get voxel sizes
    vox = diag(V.mat);
    vox = vox(1:3)';
    
    %Get data from vertices to voxels mapping
    dataidx = rave_mm2vox(surf_alt.vertices,V.dim,vox);
    data = Y(dataidx);
    
    % For volume data, the display id still determines which rois are shown
    % on the surface
    didx = rave_input('roi_displayid');
else,
    act = rave_input('roi_act');
    
    %roi_displayid is ignored when the activation is sent in with the
    %identifiers
    didx= act(:,1);
    data = act(:,2);
end;

% Load desired colormap
load(rave_input('colormap_file'));
map1 = cmap{rave_input('use_cmap')};
N = floor(length(map1)/2);

% Threshold and scale data
data = rave_threshscaledata(data,N);

% Based on the overall scaling update the voxels in Y which will be queried
% for normalized activation for each region later
if rave_input('use_roivol'),
    Y(dataidx) = data;
end;

ROIstruct = ROIpatch{rave_input('surf_id')};
% Make sure all the requested regions have a corresponding patch. If not
% show only requested regions which have a patch
if all(didx>0),
    ridx = [ROIstruct(:).id]';
    [c,idx1,idx2] = intersect(ridx,didx);
    if ~isempty(c),
        % Extract all the border vertices belonging to the ROIs to be
        % displayed and set it to 1
        ROIstruct = ROIstruct(idx1);
        didx = didx(idx2);
        if ~rave_input('use_roivol'),
            data = data(idx2);
        end;
    else,
        disp('rave_display_uniform: No matching ROIs find');
        return;
    end;
end;

% For each region to be shown determine the activity. For volume based
% input, this is reduced to a single number by using one of the statistical
% options
verts = [];
for i=1:length(ROIstruct),
    ROIverts = unique(ROIstruct(i).faces(:));
    if rave_input('use_roivol'),
        %Get data from vertices to voxels mapping
        data = Y(rave_mm2vox(surf_alt.vertices(ROIverts,:),V.dim,vox));
        switch(rave_input('roi_reduce')),
            case 0,
                data1 = round(mean(data));
            case 1,
                data1 = round(min(data));
            case 2,
                data1 = round(max(data));
            case 3,
                data1 = round(median(data));
            case 4,
                data1 = round(mode(data));
        end;
    else,
        data1 = data(i);
    end;
    switch display_type
        case 'uniform',
            if data1,
                vdata(ROIverts) = data1+N+4;
            end;
        case {'center','sphere'},
            verts = [verts;ROIverts];
            regval(i) = data1;
    end;
end

if strcmp(display_type,'center')
    sg = rave_input('roi_spread');
    for j=1:length(regval),
        ddist = surf.vertices(verts,:) - repmat(ROIstruct(j).cpatch,length(verts),1);
        dist(:,j) = sum(ddist.^2,2);
    end;
    if length(regval) == 1,
        vertval = (repmat(regval(:)',length(verts),1).*exp(-dist/(sg^2)));    
    else,
        vertval = nansum((repmat(regval(:)',length(verts),1).*exp(-dist/(sg^2)))')';    
    end;
    idx = find(round(vertval));
    vdata(verts(idx)) = round(vertval(idx)+N+4);
end;

% Check and set border vertices if required
if rave_input('show_roiborders'),
    vdata = rave_checksetborders(ROIpatch,vdata);
end;

map = [rave_input('internal_cmap');map1];
fig = rave_displaysurf(surf,vdata,map);

if strcmp(display_type,'sphere')
    [x,y,z] = sphere(20);
    [th,phi,r] = cart2sph(x,y,z);
    hold on;
    scale = rave_input('roi_spread');
    for i=find(regval),
        figure(fig);
        C = regval(i)+N+4;
        [x1,y1,z1] = sph2cart(th,phi,scale*abs(regval(i)));
        x1 = x1+ROIstruct(i).cpatch(1);
        y1 = y1+ROIstruct(i).cpatch(2);
        z1 = z1+ROIstruct(i).cpatch(3);
        m = mesh(x1,y1,z1,C*ones(size(x1)),'Facecolor',map(C,:),'Cdatamapping','direct','Facelighting','flat');
    end;
    hold off;
end;
