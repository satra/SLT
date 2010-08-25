function thisobj = subsasgn(thisobj,index,val)
% SUBSASGN  Overloaded assignment function for thisobjion class
%   THISOBJ = SUBSASGN(THISOBJ,INDEX,VAL) assigns val to the particular field of
%   the subject structure indexed to by index. This is called internally
%   by Matlab whenever you attempt to assign something to the roisession
%   structure. Currently there are no restrictions to assignment
%   (potentially dangerous as Matlab does not do type checking).

% The following has turned out to be a generic assignment statement block
% assuming full recursion of assignment [no restrictions] and that each
% element [subfields/subclasses] can perform proper assignment.

if isempty(thisobj)
    thisobj = session;
end;

switch(index(1).type),
    case '()',
        if length(index)>1
            thisobj(index(1).subs{:}) = subsasgn(thisobj(index(1).subs{:}),index(2:end),val);
        else,
	    if (length(thisobj)>=1) & strcmp(class(thisobj(end)), ...
					    class(val)),
                thisobj(index(1).subs{:}) = val;
            elseif isempty(thisobj(index(1).subs{:})) | strcmp(class(thisobj(index(1).subs{:})),class(val)),
                thisobj(index(1).subs{:}) = val;
            else,
                error([class(thisobj(index(1).subs{:})),'~=',class(val)]);
            end;
        end;
    case '.',
        if length(index)>1
            thisobj.(index(1).subs) = subsasgn(thisobj.(index(1).subs),index(2:end),val);
        else,
            if isempty(thisobj.(index(1).subs)) | strcmp(class(thisobj.(index(1).subs)),class(val)),
                thisobj.(index(1).subs) = val;
            else,
                error([class(thisobj.(index(1).subs)),'~=',class(val)]);
            end;
        end;
    otherwise,
end;
