function sap_titlechange(hdl,saveflag,title_str);

if nargin == 3,
    set(hdl,'Name',title_str);
end;

title_str = get(hdl,'Name');
if saveflag,
    set(hdl,'Name',[strtok(title_str,'*'),'*']);
else,
    set(hdl,'Name',strtok(title_str,'*'));
end;