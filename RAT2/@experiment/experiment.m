function expt = experiment(varargin)

switch (nargin),
    case 0,
        expt = create_expt;
        expt = class(expt,'experiment');
    case 1,
        if isa(varargin{1},'experiment'),
            expt = varargin{1};
        else,
	    error('Argument is not an experiment object');
        end;
    otherwise,
        disp('Incorrect argument');
end;
