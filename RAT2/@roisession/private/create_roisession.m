function session = create_roisession

session.version     = 1;
session.mask        = '';
session.surf        = ''; %surf file contains surface, transform
                          %and labels
session.issurf      = logical(0);
session.smoothed    = logical(0);
session.data        = {};
session.PUlist      = [];
session.validfiles  = [];
session.valid       = logical(0);
session.realigntxt  = '';
session.onsets      = {};
session.durations   = {};
session.covariates  = [];

% .PUname .data
