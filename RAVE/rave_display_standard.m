function varargout = rave_display_standard
% RAVE_DISPLAY_STANDARD Displays a volume of activation on the provided
% surface

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /RAVE/rave_display_standard.m 1     12/13/02 5:48p Satra $

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
    disp('rave_display_standard: the two surfaces are not similar');
    return;
end;

% Define the vertex data to be the color of sulci
vdata = 3*ones(prod(size(surf.vertices))/3,1);

% If curvature information is present load it
if rave_input('show_curvature'),
    vdata = mc{rave_input('surf_id')};
    if any(vdata<0),
	vdata = (vdata-min(vdata))/(max(vdata)-min(vdata))+2;
    end
end;

% Read in the data to be displayed
switch rave_input('use_vol'),
 case 1,
  V = spm_vol(rave_input('contrast_timg'));
  Y = spm_read_vols(V);
 case 2,
  V = spm_vol(rave_input('contrast_pimg'));
  Y = spm_read_vols(V);
  % JAY 
  Y = 1-Y;
 case 3,
  V = spm_vol(rave_input('roi_actimg'));
  Y = spm_read_vols(V);
  Y = max(Y-32000,0);
 case -1,
  V = spm_vol(rave_input('contrast_timg'));
  Y = spm_read_vols(V);
  V1 = spm_vol(rave_input('contrast_pimg'))
  Y1 = spm_read_vols(V1);
  [s,r] = strtok(strtok(V1.descrip,']'),'[');
  r = str2num(r(2:end));
  Y1(:) = sign(Y1(:)).*(1-spm_Tcdf(-abs(Y1(:)),r));
 otherwise,
  disp('rave_display_standard: use_vol is incorrect');
  return;
end;

% Jay's subcortical hack
% Define a cube around the "middle" in which we ignore everything
%ydims = [size(Y,1), size(Y,2), size(Y,3)]/2;
%cubesize = 15;
%Y(ydims(1)-cubesize:ydims(1)+cubesize,ydims(2)-cubesize:ydims(2)+cubesize,ydims(3)-1.5*cubesize:ydims(3)+0.5*cubesize) = 0;

% get voxel sizes
vox = diag(V.mat);
vox = vox(1:3)';

%Get data from vertices to voxels mapping
Yidx = rave_mm2vox(surf_alt.vertices,V.dim,V.mat);
data = Y(Yidx);

% Load desired colormap
load(rave_input('colormap_file'));
map1 = cmap{rave_input('use_cmap')};
N = floor(length(map1)/2);

if rave_input('use_vol') == -1,
    data1 = Y1(Yidx);
    data1 = rave_threshscaledata(data1,N);
    data  = data.*(abs(data1)>0);
    rave_input('thresh',0);
end
data(find(isnan(data))) = 0;

%rave_input('show_posneg',3);
data = rave_threshscaledata(data,N);
%length(find(isnan(data)))
%data = max(min(data,2),-2);
%figure;hist(data,128);figure;
%rave_input('show_posneg',0);

nonzeroidx = find(abs(data)>0);
vdata(nonzeroidx) = data(find(data))+N+4;

% Check and set border vertices if required
if rave_input('show_roiborders'),
    vdata = rave_checksetborders(ROIpatch,vdata);
end;
map = [rave_input('internal_cmap');map1];
rave_displaysurf(surf,vdata,map,map1);
varargout{1} = map;
varargout{2} = map1;
