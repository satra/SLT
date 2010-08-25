function session = create_session

session.version     = 1;
session.filenames   = {};
session.pp_affine   = {};
session.pp_full     = {};
session.validfiles  = [];
session.valid       = logical(1);
session.realigntxt  = '';
session.onsets      = {};
session.durations   = {};
session.covariates  = [];
