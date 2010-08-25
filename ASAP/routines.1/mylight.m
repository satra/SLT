function l = mylight

view(26,20);
%view(-26,20);
axis tight ;
daspect([1,.4,1])

%l = light('position',[180 130 90]);
l = light('position',[180 130 90]);
lighting gouraud;
rotate3d;
