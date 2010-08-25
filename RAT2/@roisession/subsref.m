function val = subsref(sess,index)
% SUBSREF References different fields of the class
%   VAL = SUBSREF(CLASS,INDEX) access the field indexed to by index and
%   returns the value. This is done via a recursive procedure and currently
%   allows for complete public access to all fields.

switch(index(1).type),
    case '()',
        val = sess(index(1).subs{:});
        if length(index)>1,
            val = subsref(val,index(2:end));
        end;
    case '.',
        val = sess.(index(1).subs);
        if length(index)>1,
            val = subsref(val,index(2:end));
        end
    otherwise,
end