function curpos = sap_updatecurpos(plane,slice,pt)

curpos(4) = plane;
switch plane,
case 1,
    curpos(1) = slice;
    curpos([2,3]) = pt;
case 2,
    curpos(2) = slice;
    curpos([1,3]) = pt;
case 3,
    curpos(3) = slice;
    curpos([1,2]) = pt;
end;
