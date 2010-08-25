function ptlist = sap_drawpts(ptlist,col,marker);
if ~isempty(ptlist),
   hold on;
   h = line(ptlist(:,1),ptlist(:,2),'Marker',marker,'Color',col);
   hold off;
   [x,y,N] = sap_ginput(1);
   delete(h);
else,
   [x,y,N] = sap_ginput(1);
end;
while(N ~= 3),
   if N == 2,
      ptlist = ptlist(1:end-1,:);
   else,
      ptlist = [ptlist;x y];
   end;
   if ~isempty(ptlist),
      hold on;
      h = line(ptlist(:,1),ptlist(:,2),'Marker',marker,'Color',col);
      hold off;
      [x,y,N] = sap_ginput(1);
      delete(h);
   else,
      [x,y,N] = sap_ginput(1);      
   end;
end;
