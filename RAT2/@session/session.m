function sess = session(varargin)

switch nargin,
    case 0,
        sess = create_session;
        sess = class(sess,'session');
    case 1,
        if isa(varargin{1},'session'),
            sess = varargin{1};
        else,
            sess = session;
        end;
    otherwise,
end;