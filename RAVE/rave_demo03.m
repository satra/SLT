%function rave_demo03

rave_command('init');
basedir = fileparts(which(mfilename));

rave_input('surf_file',fullfile(basedir,'data','surfdata.mat'));
rave_input('surf_id',1);
rave_input('surf_altid',1); % might be removed to the surf data file itself

rave_input('roi_actimg',fullfile(basedir,'data','Results_F0301.img'));

load(fullfile(basedir,'data','roiactivity.mat'));
act(1:end-2,2) = 0;
act(end-1,2) = -1.5;
act(end,2) = 2.5;

rave_input('roi_act',act);

rave_input('roi_reduce',0);
rave_input('show_posneg',0);

rave_input('show_curvature',1);
rave_input('roi_displayid',-1);
rave_input('show_roiborders',1);
rave_input('surf_alpha',0.5);

rave_input('use_roivol',0);
rave_input('thresh',100);
rave_input('maxval',3);

rave_input('roi_spread',0.4);
rave_input('show_act',4);

%rave_input('roi_spread',4);
%rave_input('show_act',3);

%rave_input('roi_spread',4);
%rave_input('show_act',2);

rave_command('display');
