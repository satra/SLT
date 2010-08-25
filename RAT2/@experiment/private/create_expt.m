function experiment = create_expt

% Title of experiment
experiment.version      = 1;
experiment.name         = '';
experiment.startdate    = '';
experiment.enddate      = '';
experiment.desc         = '';
experiment.design       = struct([]);
experiment.subject      = struct([]);
experiment.contrast     = struct([]);
%experiment.L2_contrast  = struct([]);
experiment.L2_contrast(1).c     = [1];
experiment.L2_contrast(1).name  = 'Level2 contrast';
experiment.L2_contrast(1).stat  = 'T';

experiment.version      = 2;
experiment.filename     = '';
