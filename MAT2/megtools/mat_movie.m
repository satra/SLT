function [frames] = mat_movie(M,skip,surf,mySize,myZoom,filename)


maxVal = max(abs(M(:)));
nv = length(surf.vertices);

h = figure('position',[100 100 mySize mySize*1.5]);
set(h,'DoubleBuffer','on');
colormap(slowbr(64));
subplot(11,1,1:5);
p = patch('Vertices',surf.vertices,'Faces',surf.faces,'EdgeColor','none','FaceColor','interp','FaceVertexCdata',32*ones(nv,1),...
          'FaceLighting','gouraud','CDataMapping','Direct');
axis equal off;
view([0 90 10]);
zoom(myZoom);
camlight;
material dull;
cb = colorbar('vert');
set(cb,'YTick',[32],'YTickLabel',0);

subplot(11,1,6:10);
p2 = patch('Vertices',surf.vertices,'Faces',surf.faces,'EdgeColor','none','FaceColor','interp','FaceVertexCdata',32*ones(nv,1),...
           'FaceLighting','gouraud','CDataMapping','Direct');
axis equal off;
view([0 -90 10]);
zoom(myZoom);
camlight;
material dull;
cb2 = colorbar('vert');
set(cb2,'YTick',[32],'YTickLabel',0);

subplot(11,1,11); 
barh(0.1,0,0.1);
axis([0 size(M,2) 0 0.2]);
xlabel('Time (ms)');

MakeQTMovie('start',filename);
%count = 1;
for i=1:skip:size(M,2),
    set(p,'FaceVertexCdata',(M(:,i))./maxVal.*32 + 32); drawnow;
    set(p2,'FaceVertexCdata',(M(:,i))./maxVal.*32 + 32); drawnow;
    subplot(11,1,11);
    bh = barh(0.1,i,0.1); set(gca,'YTick',[],'YTickLabel',{}); axis([0 size(M,2) 0 0.2]);
    MakeQTMovie('addframe');
%     frames(count) = getframe(h);
%     count = count+1;
end;

MakeQTMovie('finish');
%movie2avi(frames,filename,'compression','Indeo5','quality',50,'fps',25);

