function roi_Fig_create_left_gray(results)

if ischar(results),
    load(results);
end
%load Results_9_16_03.mat; 

% Hack for filling in MC
id1 = find(strcmp(results.title{1},'LeftpdPMC'));
id2 = find(strcmp(results.title{1},'LeftvPMC'));
results.F(end+1,:) = results.F(id1,:);
results.F(end+1,:) = results.F(id2,:);
results.p(end+1,:) = results.p(id1,:);
results.p(end+1,:) = results.p(id2,:);
results.ROI_ids(end+1) = id1;
results.ROI_ids(end+1) = id2;
results.title{1}{end+1} = 'LeftdMC';
results.title{1}{end+1} = 'LeftvMC';

[l,i] = sap_getLabels;
try
for i=1:length(results.title{1}),
    ROI_idx(i,1) = find(strcmp(l,results.title{1}{i}));
end;
results.ROI_ids = ROI_idx;
catch
end
results.Contrasts = results.title{2}';

significance = 0.05;
idx = find(results.p(:)<=0.0001);
maxFval = min(abs(results.F(idx)));

%maxFval = min(max(abs(results.F(:))),15);
load lh_data;
load bwmap;
jmap=bwmap;
[img,map] = imread('Left_Cereb_detached.gif'); 
map = map(1:(double(max(img(:)))+1),:);


for i=[52],%[1:size(results.p,2)],
    
    ind=find(results.p(:,i)<=significance);
    PUids = results.ROI_ids(ind);
    leftids = find(PUids>32000);
    %rightids= find(PUids<32000);
    PUleftids=PUids(leftids)-32000;
    %PUrightids=PUids(rightids);
    
    F = results.F(ind,i);
    Fleft = F(leftids);
    %Fright= F(rightids);
    
    
    lhpatchid = find([lh(:).done]');
    
    ids2draw = intersect(lhpatchid,PUleftids);
    count = 0;
    p = {};
    img1 = zeros(size(img));
    jmap = [.3 .3 .3;1 1 1; .7 .7 .7];%DANGER!!! swapped
                                            %values to reverse easy
                                            %vs. hard discrim contrast
    for pu = ids2draw(:)',
        count = count+1;
	if ~isempty(intersect(PUleftids,pu)),
	    val = Fleft(find(PUleftids==pu));
	    if val<0
		val = 1;
	    else
		val = 3;
	    end;
	else,
	    val = 2;
	end
        actcol = jmap(val,:);
        % draw patch
        if ~isempty(lh(pu).points),
            fv.vertices = round(lh(pu).points);
            img1 = img1+~img1.*(val*double(roipoly(img1,fv.vertices(:,1),fv.vertices(:,2))));
            %fv.faces = [1:size(lh(pu).points,1)];
            %p{count} = patch(fv,'edgecolor','k','facecolor',actcol);
        elseif lh(pu).done==1 & ~isempty(lh(pu).med_points),
            fv.vertices = [lh(pu).med_points];
            %fv.faces = [1:size(lh(pu).med_points,1)];
            img1 = img1+~img1.*(val*double(roipoly(img1,fv.vertices(:,1),fv.vertices(:,2))));
            %p{count} = patch(fv,'edgecolor','k','facecolor',actcol);
            fv.vertices = [lh(pu).lat_points];
            img1 = img1+~img1.*(val*double(roipoly(img1,fv.vertices(:,1),fv.vertices(:,2))));
            %fv.faces = [1:size(lh(pu).lat_points,1)];
            %p{count} = [p{count}, patch(fv,'edgecolor','k','facecolor',actcol)];
        end
    end;
    
    imgb = img;
    %imgb(find(imgb(:)<=8)) = 0;
    imgb(find(imgb(:)<=(double(max(img(:)))-1))) = 0;
    rgb1 = ind2rgb(imgb,map);
    jmap1 = jmap;
    jmap1(end+1,:) = [1 1 1];
    img1(find(img1(:)==0))=size(jmap1,1);
    rgb2 = ind2rgb(img1,jmap1);
    img3 = zeros(size(img));
    idx = find(img(:)==max(img(:)));
    %idx = find(img(:)==15);
    img3(idx) = 1;
    img3 = img3(:,:,ones(3,1,1));

    alpha = 1;
    [img2,map2] = rgb2ind((1-img3).*rgb1+img3.*((1-alpha).*rgb1+alpha.*rgb2),128);
    f1=figure('Doublebuffer','on');
    colormap(map2);
    imgh = image(img2); axis image; axis off; hold on;
    title(['Contrast: ',char(results.Contrasts(i)),' [LH]'],'fontsize',12,'fontweight','bold');
    a = axes('position',[0.22 0.15 0.6 0.03]);
    image(linspace(-maxFval,maxFval,size(jmap,1)),1, shiftdim(jmap,-1));
    set(gca,'ytick',[],'yticklabel',[],'xtick',linspace(fix(-maxFval),fix(maxFval),3),...
        'xticklabel',{sprintf('%d<',fix(-maxFval)),'0',sprintf('>%d',fix(maxFval))},'fontweight','bold');
    %imwrite(img2,map2,sprintf('lh.contrast_%d.jpg',i),'jpeg','quality',100);
    imgfile = sprintf('lh.contrast_%s.jpg',results.Contrasts{i});
    print('-djpeg99',imgfile);
    roi_autocropimg(imgfile);
end

%delete(imgh)
%print('test01.gif','-djpeg');
