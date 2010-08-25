function dsgn = create_design
% DSGN = CREATE_DESIGN sets all the fields of the design class. 

dsgn.version            = 3;
dsgn.type               = ''; % 'block','trigger','event'
dsgn.TR                 = 0; % Repetition time
%dsgn.maxsessionsperexpt = 1;
%dsgn.minsessionsperexpt = 1;
%dsgn.numsessions        = 1;
dsgn.volumespertrigger  = 1; 
%dsgn.eventspersession   = [];
dsgn.volumespersession  = 1;
dsgn.condnames          = {}; % names of different parametric conditions
dsgn.blocklength        = []; % length of each condition block. Can
                              % be a scalar if all blocks are of
                              % the same duration, or a vector otherwise.
dsgn.detrend            = 1;
dsgn.runinfo            = ''; % name of the MAT file containing
                              % runinfo
dsgn.runinfotype        = 1; % 1 - per subject, 2 - per experiment


% specify data: session/subject independent 

% SPM specific parameters
% basis functions and timing parameters
%---------------------------------------------------------------------------
% OPTIONS:'hrf'
%         'hrf (with time derivative)'
%         'hrf (with time and dispersion derivatives)'
%         'Fourier set'
%         'Fourier set (Hanning)'
%         'Gamma functions'
%         'Finite Impulse Response'
%---------------------------------------------------------------------------
dsgn.xBF_name       = ''; %'Finite Impulse Response';
dsgn.xBF_length     = []; % 6;        % length in seconds
dsgn.xBF_order      = []; %1;        % order of basis set
dsgn.xBF_T          = []; %30;       % number of time bins per scan
dsgn.xBF_T0         = []; %1;        % first time bin (see slice timing)
dsgn.xBF_UNITS      = ''; %'scans';  % OPTIONS: 'scans'|'secs' for onsets
dsgn.xBF_Volterra   = []; %1;        % OPTIONS: 1|2 = order of convolution

%===========================================================================
% global normalization: OPTINS:'Scaling'|'None'
%---------------------------------------------------------------------------
dsgn.xGX_iGXcalc    = ''; %'Scaling';

% low frequency confound: high-pass cutoff (secs) [Inf = no filtering]
%---------------------------------------------------------------------------
dsgn.xX_K_HParam    = inf;   % High Param
dsgn.xX_K_LParam    = 0;     % Low Param

% intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
%-----------------------------------------------------------------------
dsgn.xVi_form       = ''; %'none';

% ROI Analyses specific parameters
dsgn.RemoveGlobal   =  0;
dsgn.roiSmoothFWHM  = []; % 12; % Intra region smoothing
dsgn.L2_X           = []; % Level 2 design matrix
dsgn.whitening      = 1;  % Whether or not to whiten the data
dsgn.dataReductionType = 'FFT'; % Type of data reduction 'FFT' or 'SVD'  
dsgn.dataReductionLevel = 15; % Number of data reduction components kept  
dsgn.useSPHcoords   = 1; % Whether to use spherical coordinates or
                         % not during ROI analyses.This depends on
                         % whether the mask data was generated
                         % using freesurfer
