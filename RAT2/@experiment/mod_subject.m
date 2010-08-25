function expt = mod_subject(expt,sid,varargin);

if nargin<3 | isempty(varargin{1}),
    return;
end;

nid = 1;
switch lower(varargin{1}),
    case {'id','design'},
        expt.subject(sid).(varargin{1}) = varargin{2};
        nid = 3;
    case {'roimask','structural','hires','functional'}
        if isa(varargin{2},'session'),
            val = varargin{2};
            nid = 3;
        else,
            val = varargin{3};
            nid = 4;
        end;
        if isempty(expt.subject(sid).(varargin{1})),
            if ~isa(varargin{2},'session') & varargin{2}~=1,
                disp('structure is empty. adding to position 1');
            end;
            expt.subject(sid).(varargin{1}) = val;
        else,
            if isa(varargin{2},'session'),
                expt.subject(sid).(varargin{1})(length(expt.subject(sid).(varargin{1}))+1,1) = val;
            else,
                expt.subject(sid).(varargin{1})(varargin{2},1) = val;
            end;
        end;
    otherwise,
end;
expt = mod_subject(expt,sid,varargin{nid:end});