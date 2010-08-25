%function rave_demo02

rave_command('init');

basedir = fileparts(which(mfilename));
rave_input('surf_file',fullfile(basedir,'data','surfdata.mat'));

rave_input('surf_id',2);
rave_input('surf_altid',1); % might be removed to the surf data file itself

rave_input('contrast_timg',fullfile(basedir,'data','Results_F0301.img'));
% or
rave_input('contrast_pimg',fullfile(basedir,'data','Results_P0301.img'));
% or
rave_input('roi_actimg',fullfile(basedir,'data','nROImask_corr_nsubject.09.Series.003.img'));

rave_input('use_vol',2);

rave_input('show_posneg',0);
rave_input('thresh',0.05);
rave_input('maxval',1);

rave_input('show_curvature',1);
rave_input('roi_displayid',-1);
rave_input('show_roiborders',1);
rave_input('surf_alpha',1);

rave_input('show_act',1);

rave_command('display');
