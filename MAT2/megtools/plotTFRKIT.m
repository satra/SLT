function plotTFRKIT(data)

load sensors;

coil_coord = sensorLocs(:,1:3);

sx = coil_coord(:,1);
sy = coil_coord(:,2);
sz = coil_coord(:,3);

[th2,phi2,r2] = cart2sph(sx,sy,sz);
[xp2,yp2] = pol2cart(th2+pi/2,r2.*(pi/2-phi2));

figure('Doublebuffer','on','menu','none');
axes('units','normalized','position',[0 0 1 1]);

plot(xp2,yp2,'o');
text(xp2,yp2,num2str([1:93]'));
axis off;

pos = get(gca,'position');
xlim = get(gca,'xlim');
ylim = get(gca,'ylim');
xp3 = pos(1)+pos(3)*(xp2-xlim(1))/(xlim(2)-xlim(1));
yp3 = pos(2)+pos(4)*(yp2-ylim(1))/(ylim(2)-ylim(1));

width = 0.06;
height = 0.06;

for i=1:93,
    axhdl(i) = axes('position',[xp3(i)-width/2,yp3(i)-height,width,height]);
    image(squeeze(data(:,:,i)));axis xy;
    axis off;
    drawnow;
end;
