function subj = subject(varargin),

switch nargin,
    case 0,
        subj = create_subject;
        subj = class(subj,'subject');
    case 1,
        if isa(varargin{1},'subject'),
            subj = varargin{1};
        else,
            subj = subject;
        end;
    otherwise,
end;
        