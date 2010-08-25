function sap_drawcb(arg,pts,col,mark)

persistent fighdl lhdl ptlist color marker btnflag

switch(arg),
case 'init',
    fighdl = gcbf;
    lhdl = [];
    ptlist = pts;
    color = col;
    marker=mark;
    btnflag = 0;
    lhdl = drawpts(lhdl,ptlist,color,marker);
case 'down',
    button =  getbuttontype(fighdl);
    if button == 1,
        btnflag = 1;
    end;
case 'up',
    button =  getbuttontype(fighdl);
    switch button,
    case 1,
    if btnflag,
        newpt = get(gca,'CurrentPoint');
        ptlist = [ptlist;newpt(1,2)];
        lhdl = drawpts(lhdl,ptlist,color,marker);
    end;
    btnflag = 0;
    case 2,
      ptlist = ptlist(1:(end-1),:);
      lhdl = drawpts(lhdl,ptlist,color,marker);
    case 3,
        setappdata(fighdl,'done',1);
        setappdata(fighdl,'ptlist',ptlist);
    end;
case 'move',
    if btnflag,
        newpt = get(gca,'CurrentPoint');
        ptlist = [ptlist;newpt(1,2)];
        lhdl = drawpts(lhdl,ptlist,color,marker);
    end;
otherwise,
    arg
    error('Unknown argument');
end

function lhdl = drawpts(lhdl,ptlist,col,marker)
if ~isempty(lhdl),
    delete(lhdl);
end
if ~isempty(ptlist),
    hold on;
    lhdl = line(ptlist(:,1),ptlist(:,2),'Marker',marker,'Color',col);
    hold off;
end;

function button = getbuttontype(fighdl)
button = get(fighdl, 'SelectionType');
if strcmp(button,'normal')
    button = 1;
elseif strcmp(button,'extend')
    button = 2;
elseif strcmp(button,'alt')
    button = 3;
else
    error('Invalid mouse selection.')
end
