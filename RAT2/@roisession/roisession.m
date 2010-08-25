function sess = roisession(varargin)

switch nargin,
    case 0,
        sess = create_roisession;
        sess = class(sess,'roisession');
    case 1,
        if isa(varargin{1},'roisession'),
            sess = varargin{1};
        else,
            sess = roisession;
        end;
    otherwise,
end;
