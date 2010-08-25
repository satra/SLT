function list = sap_interp(ptlist)

if isempty(ptlist),
    list = ptlist;
    return;
end;
ptlist = round(ptlist);
list = ptlist(1,:);
for i=2:size(ptlist,1),
    xy= ptlist(i-1:i,:);
    numpts = max(abs(diff(xy)))+1;

    tmplist = [];
    tmplist(:,1) = round(linspace(xy(1,1),xy(2,1),numpts))';
    tmplist(:,2) = round(linspace(xy(1,2),xy(2,2),numpts))';
    list = [list;tmplist(2:end,:)];
end;
