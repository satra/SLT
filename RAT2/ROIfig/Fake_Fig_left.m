function [img2,map2] = Fake_Fig_left(results,jmap)

if nargin<2 | isempty(jmap),
    load rbmap;
    jmap =rbmap;
    %load bwmap.mat;
    %jmap = bwmap;
end;
 
load lh_data;

F = results.Fx;

%%%%%change background plot here%%%%%%
[img,map] = imread('Left_Cereb_detached.tif'); 
[img,map] = cmunique(img,map);

%i=1;
    PUids = results.ROIids;
    lhpatchid = find([lh(:).done]');
    img1 = zeros(size(img));
    maxFval = max(F);%mean(abs(F))+std(abs(F));
    ids2draw = intersect(PUids,lhpatchid);
    for pu=PUids(:)', 
        val = floor((F(find(PUids==pu))/maxFval)*(size(jmap,1)*2));
        %val=round(64.5+64*min(max(F(find(PUids==pu))/maxFval,-1),1));
        disp(val)
        %actcol = jmap(val,:);
        %count = count+1;
        % draw patch
        if ~isempty(lh((pu)).points),
            fv.vertices = round(lh(pu).points);
            img1 = img1+~img1.*(val*double(roipoly(img1,fv.vertices(:,1),fv.vertices(:,2))));
        elseif lh(pu).done==1 & ~isempty(lh(pu).med_points),
            fv.vertices = [lh(pu).med_points];
            img1 = img1+~img1.*(val*double(roipoly(img1,fv.vertices(:,1),fv.vertices(:,2))));
            %p{count} = patch(fv,'edgecolor','k','facecolor',actcol);
            fv.vertices = [lh(pu).lat_points];
            img1 = img1+~img1.*(val*double(roipoly(img1,fv.vertices(:,1),fv.vertices(:,2))));
            %p{count} = [p{count}, patch(fv,'edgecolor','k','facecolor',actcol)];
        end
    end;
    imgb = img;
    whiteidx = find(sum(map,2)==3)-1;
    rgb1 = ind2rgb(imgb,map); % blank ROI figure
    jmap1 = [1 1 1;jmap]; 
    rgb2 = ind2rgb(uint8(img1),jmap1);
    img3 = zeros(size(img));
    idx = find(img(:)==whiteidx);
    img3(idx) = 1;
    img3 = img3(:,:,ones(3,1,1));
    alpha = 1;
    [img2,map2] = rgb2ind((1-img3).*rgb1+img3.*((1-alpha).*rgb1+alpha.*rgb2),128);
    f1=figure('Doublebuffer','on');
    colormap(map2);
    imgh = image(img2); axis image; axis off; hold on;
    title(sprintf('%s[p%0.1g]'),'fontsize',10,'fontweight','bold');
    imgfile = sprintf('Fake%s[p%0.1g]_LH.tif');

    %imgfile = sprintf('lh.%03d.contrast_%s.jpg',i,results.Contrasts{i});
    %print('-dtiff','-r300',imgfile);
    %roi_autocropimg(imgfile,'tiff');

