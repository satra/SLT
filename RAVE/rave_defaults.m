function raves = rave_defaults
%RAVE_DEFAULTS Generates the RAVE default structure with values
%   Each section of this file states the requirements for each field. 
%   If you are using your own files, be sure to read this.
%
%   See also RAVE_COMMAND, RAVE_INPUT

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /RAVE/rave_defaults.m 1     12/13/02 5:48p Satra $

% $NoKeywords: $


% Get RAVE directory location
RWD = fileparts(which(mfilename));
DATADIR  = [RWD,filesep,'data',filesep];

% rave structure creation

% [surface]
% Each surface file should have minimally the following variables:
%   fv          : A struct array containing faces vertices for each surface
%                 contained in the file
%   Optional information:
%   idx         : voxel identifier for each vertex [assumes a surf 2 img
%                 correspondence] (Struct array corresponding to fv) 
%   mc          : Curvature information (Struct array corresponding to fv)
%                 2 -ve [gyri] 3 +ve  [sulci]
%   ROIpatch    : A array of struct arrays each of which contain these  fields
%       - id    : ROI identifier
%       - label : ROI Label
%       - faces : Patch faces [vertices will be picked up from the surface
%                 vertices]
%       - faceid: corresponding index into fv(i).faces
%       - bvert : Boundary vertices for the ROI
%       - cpatch: Center of the Patch
raves.surf_file              = '';
% -flags-
raves.surf_hasidx            = 0;
raves.surf_hascurvature      = 0;
raves.surf_haspatch          = 0;

% [roiinfo]
% The mat file contains a struct array called label with fields
%   -name : Label Name
%   -id   : identifier
raves.roi_label     = [DATADIR,'roilabel.mat'];
raves.has_roilabel  = 1;

% [input files]
% The following set of input files have to be in the same voxel space
% as the surface file [essentially coregistered]. In addition, they can 
% either be Analyze (*.img,*.hdr) volumes or Matlab (*.mat) files
raves.structural_img    = '';
raves.contrast_timg     = '';   % Actual Statistical test size
raves.contrast_pimg     = '';   % P-value
raves.roi_actimg        = '';
raves.contrast_label    = '';
% -flags-
raves.has_structural    = 0;
raves.has_tcontrast     = 0;
raves.has_pcontrast     = 0;
raves.has_roivol     = 0;
% ROI activity is a 2D array. The first column stores the ROI IDs. 
% The second column provides the actual activity
raves.roi_act     = [];
% -flags-
raves.has_roiact        = 0;
raves.use_vol           = 1; % [1 tcontrast 2 pcontrast 3 roivol]
raves.use_roivol        = 0; % Uses act array by default [1 vol 0 array]

% [parameters]
raves.surf_id           = 2;    % default first surface of surf array [inflated]
raves.surf_altid        = 1;    % default first surface of surf array [convoluted]
raves.has_altid         = 0;
raves.roi_displayid     = 0;   % 0 show none, -1 show all, array contains indices
raves.roi_spread        = 1;    % Gaussian spread with sigma = 1
raves.roi_reduce        = 0;    % 0 mean, 1 min, 2 max, 3 median, 4 mode, functional_handle

raves.thresh            = 5;    % show top 5% of activity
% Since the activity needs to be compressed within the colormap at some
% stage raves.maxval/minval provides for a normalization scheme
raves.maxval            = 100; 
% Colormaps should have an odd number of entries, such that the middle
% entry maps to background. Cell array of colormaps
raves.colormap_file     = [DATADIR,'colormaps.mat']; 
raves.use_cmap          = 1;
raves.internal_cmap     = [0 0 0;0.5 0.5 0.5;0.75 0.75 0.75];

% Surface and patch transparency
raves.surf_alpha        = 1;
raves.roi_alpha         = 1;

% [display options]
raves.show_posneg       = 0;    % +1 pos, 0 both, -1, neg
raves.show_roiborders  = 0;    % Boolean
raves.show_curvature    = 1;    % Boolean
raves.show_act      = 0;    
% 0 [none]  Don't display any activity
% 1 [standard]  Use whole volume info instead of ROI activity
% 2 [uniform]   All vertices for an ROI have the same activity
% 3 [center]    Activity spreads out from centerpos
% 4 [sphere]    Activity at centerpos, color/radius of sphere

% [version]
raves.version           = 0.2;

raves.dofdrthresh       = 0;
raves.fdrthresh         = 0.05;

% [Future use]
