function dsgn = design_setup_trigger01
% DSGN = DESIGN_SETUP_TEMPLATE sets up the design of the study in a design
% object. You could modify this routine to setup a subject specific design
% or you could create a global design from which you extract subject
% specific features in SUBJECT_SETUP_TEMPLATE

dsgn = design;

dsgn.runinfo            = 'runinfo_trigger01.mat';
dsgn.runinfotype        = 2;

dsgn.TR                 = 2.25;
dsgn.volumespertrigger  = 2;
dsgn.volumespersession  = 96;
dsgn.condnames = {'condition_A','condition_B','Silence'};

dsgn.xBF_length         = 4.5;
dsgn.xBF_T              = 32;

dsgn.xBF_name       = 'Finite Impulse Response';    % use the hemodynamic response function model
dsgn.xBF_UNITS      = 'scans';   % OPTIONS: 'scans'|'secs' for onsets
dsgn.xX_K_HParam    = inf;

dsgn.xBF_order      = 1;
dsgn.xBF_T0         = 1;
dsgn.xBF_Volterra   = 1;
dsgn.xGX_iGXcalc    = 'Scaling';
dsgn.xVi_form       = 'none';

dsgn.roiSmoothFWHM  = '4';

