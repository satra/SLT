function hdlcopy(a,b,c);
Fa=set(a);
Ga=fieldnames(Fa);
if nargin<3,
    for n1=1:length(Ga),
        set(b,Ga{n1},get(a,Ga{n1}));
    end
else,
    for n1=1:length(c),
        idx=strmatch(lower(c{n1}),lower(Ga),'exact');
        if ~isempty(idx), 
            set(b,Ga{idx},get(a,Ga{idx}));
        end
    end
end
