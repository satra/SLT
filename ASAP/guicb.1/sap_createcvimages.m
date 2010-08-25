function sap_createcvimages(handles)

axh = [handles.sap_sagaxs handles.sap_coraxs handles.sap_axiaxs];
for i=1:3,
    axes(axh(i));
    imh = image;
    set(imh,'HitTest','off','Parent',axh(i),'Erasemode','none');
    axis('image','xy');
    hold on;
    clientid = sap_clientmanager('addclient',axh(i),[],handles,'cvaxis',imh,i);
    set(axh(i),'userdata',clientid,'Clim',[0 1]);
end;