function sap_createwksimages(handles)

set(handles.sap_wks,'Units','pixels');
pos = get(handles.sap_wks,'Position');
set(handles.sap_wks,'Units','normalized');
posn = get(handles.sap_wks,'Position');
n = round(get(handles.sap_slnum,'Value'));

rat = pos(3)/pos(4);
post = posn(2)+posn(4);
posb = posn(2);
posl = posn(1);
posr = posn(1)+posn(3);
posw = posn(3);
posh = posn(4);
nd = round(sqrt(n/rat));
nr = ceil(n/nd);

df = 1; % drawing fraction
ef = 1-df; % empty fraction
nwr = df*posw/nr;
nwd = df*posh/nd;
if (nr ==1),
   nwrd = ef*posw;
else,
   nwrd = ef*posw/(nr-1);
end;
if (nd ==1),
   nwdd = ef*posh;
else,
   nwdd = ef*posh/(nd-1);
end;

pos1(2) = post;
pos1(3) = nwr;
pos1(4) = nwd;
ct = 0;axh = [];imh = [];
for i=1:nd,
   pos1(1) = posl;
   pos1(2) = pos1(2)-nwd;
   for j=1:nr,
      ct = ct+1;
      str = 'sap_clientmanager(''buttondowncb'',gcbo,[],guihandles(gcbf));';
      axh(ct) = axes('Parent',handles.sap_mainfrm,...
         'Position',pos1,...
         'XTick',[],'YTick',[],'XTickLabel',[],...
         'ButtonDownFcn',str,'Color',[0 0.15 0.15],...
         'UIContextMenu',handles.sap_browsemenu,...
         'ButtonDownFcn',str);
      imh(ct) = image;
      set(imh(ct),'HitTest','off','Parent',axh(ct),'Erasemode','none');
      pos1(1) = pos1(1)+nwr+nwrd;
      axis('image','xy');
      hold on;
      udata.clientid = sap_clientmanager('addclient',axh(ct),[],handles,'wksaxis',imh(ct),ct);
      set(axh(ct),'userdata',udata);
      if (ct == n),
         break;
      end;
   end;      
   pos1(2) = pos1(2)-nwdd;
end;
