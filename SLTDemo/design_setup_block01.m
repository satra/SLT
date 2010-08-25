function dsgn = design_setup_block01
% DSGN = DESIGN_SETUP_TEMPLATE sets up the design of the study in a design
% object. You could modify this routine to setup a subject specific design
% or you could create a global design from which you extract subject
% specific features in SUBJECT_SETUP_TEMPLATE

dsgn = design;

dsgn.runinfo            = 'runinfo_block01.mat';
dsgn.runinfotype        = 2;

dsgn.TR                 = 3;
dsgn.volumespersession  = 130;
dsgn.condnames    = {'condition_A','condition_B','Silence'};
dsgn.blocklength  = [30,30,15];

dsgn.xBF_length         = 32.2;
dsgn.xBF_T              = 30;

dsgn.xBF_name       = 'hrf';    % use the hemodynamic response function model
dsgn.xBF_UNITS      = 'secs';   % OPTIONS: 'scans'|'secs' for onsets
dsgn.xX_K_HParam    = 390;

dsgn.xBF_order      = 1;
dsgn.xBF_T0         = 1;
dsgn.xBF_Volterra   = 1;
dsgn.xGX_iGXcalc    = 'Scaling';
dsgn.xVi_form       = 'AR(1) + w';

dsgn.roiSmoothFWHM  = '4';

