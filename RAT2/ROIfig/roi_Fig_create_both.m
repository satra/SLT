function roi_Fig_create_both(results,i,img1,map1,img2,map2,maxFval,jmap)

results.Contrasts = results.title{2}';
%%
f1=figure('Doublebuffer','on');
img = [img2;size(map2,1)+img1];
map = [map2;map1];
colormap(map);
imgh = image(img); axis image; axis off; hold on;
% title(['Contrast: ',char(results.Contrasts(i)),' [LH]'],'fontsize',12,'fontweight','bold');

% draw colorbar
if ~isempty(jmap)
    a = axes('position',[0.37 0.1 0.3 0.015]);
    image(linspace(-maxFval,maxFval,size(jmap,1)),1, shiftdim(jmap,-1));
    set(gca,'ytick',[],'yticklabel',[],'xtick',linspace(-maxFval,maxFval,3),...
        'xticklabel',{sprintf('%2.2f<',-maxFval),'0',sprintf('>%2.2f',maxFval)},'fontweight','bold');
end
imgfile = sprintf('both.%03d.contrast_%s.tif',i,results.Contrasts{i});
print('-dtiff','-r600',imgfile);
roi_autocropimg(imgfile,'tiff');
fprintf('Finished cropping: %s\n',imgfile);
