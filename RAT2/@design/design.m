function dsgn = design(varargin)

switch nargin
    case 0,
        dsgn = create_design;
        dsgn = class(dsgn,'design');
    case 1,
        if isa(varargin{1},'design'),
            dsgn = varargin{1};
        elseif isstruct(varargin{1}),
	    inputstruct = varargin{1};
	    names = fieldnames(inputstruct);
	    dsgn = design;
	    for f0=1:length(names),
		dsgn.(names{f0}) = inputstruct.(names{f0});
	    end
	else
            dsgn = design;
        end;
    otherwise,
end;
