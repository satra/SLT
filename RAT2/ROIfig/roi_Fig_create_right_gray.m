function roi_Fig_create_right_gray(results)

if ischar(results),
    load(results);
end
%load Results_9_16_03.mat;

% Hack for filling in MC
id1 = find(strcmp(results.title{1},'RightpdPMC'));
id2 = find(strcmp(results.title{1},'RightvPMC'));
results.F(end+1,:) = results.F(id1,:);
results.F(end+1,:) = results.F(id2,:);
results.p(end+1,:) = results.p(id1,:);
results.p(end+1,:) = results.p(id2,:);
results.ROI_ids(end+1) = id1;
results.ROI_ids(end+1) = id2;
results.title{1}{end+1} = 'RightdMC';
results.title{1}{end+1} = 'RightvMC';

[l,i] = sap_getLabels;
try,
for i=1:length(results.title{1}),
    ROI_idx(i,1) = find(strcmp(l,results.title{1}{i}));
end;
results.ROI_ids = ROI_idx;
catch,
end

results.Contrasts = results.title{2}';

significance = 0.05;
idx = find(results.p(:)<=0.0001);
maxFval = min(abs(results.F(idx)));
%maxFval = min(max(abs(results.F(:))),15);
load rh_data;
load bwmap;
jmap=bwmap;
[img,map] = imread('Right_Cereb_detached.gif'); 
map = map(1:(double(max(img(:)))+1),:);

for i=[47]%1:size(results.p,2),
    
    ind=find(results.p(:,i)<=significance);
    PUids = results.ROI_ids(ind);
    rightids= find(PUids<32000);

    PUrightids=PUids(rightids)
    F = results.F(ind,i);

    Fright= F(rightids);
    rhpatchid =  find([rh(:).done]');
    
    ids2draw = intersect(rhpatchid,PUrightids);
    count = 0;
    p = {};
    img1 = zeros(size(img));
    jmap = [.3 .3 .3;1 1 1; .7 .7 .7];%DANGER!!! swapped
                                            %values to reverse easy
                                            %vs. hard discrim contrast
                                          
    for pu = rhpatchid(:)', %PUrightids, %ids2draw(:)',
        count = count+1;
	if ~isempty(intersect(PUrightids,pu)),
	    val = Fright(find(PUrightids==pu));
	    if val<0,
		val = 1;
	    else
		val = 3;
	    end;
	else,
	    val = 2;
	end
	actcol = jmap(val,:);;
        % draw patch
        if ~isempty(rh(pu).points),
            fv.vertices = round(rh(pu).points);
            img1 = img1+~img1.*(val*double(roipoly(img1,fv.vertices(:,1),fv.vertices(:,2))));
            fv.faces = [1:size(rh(pu).points,1)];
            p{count} = patch(fv,'edgecolor','k','facecolor',actcol);
        elseif rh(pu).done==1 & ~isempty(rh(pu).med_points),
            fv.vertices = [rh(pu).med_points];
            fv.faces = [1:size(rh(pu).med_points,1)];
            img1 = img1+~img1.*(val*double(roipoly(img1,fv.vertices(:,1),fv.vertices(:,2))));
            p{count} = patch(fv,'edgecolor','k','facecolor',actcol);
            fv.vertices = [rh(pu).lat_points];
            img1 = img1+~img1.*(val*double(roipoly(img1,fv.vertices(:,1),fv.vertices(:,2))));
            fv.faces = [1:size(rh(pu).lat_points,1)];
            p{count} = [p{count}, patch(fv,'edgecolor','k','facecolor',actcol)];
        end
    end;
%    figure;colormap(jmap);image(img1);

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
    title(['Contrast: ',char(results.Contrasts(i)),' [RH]'],'fontsize',12,'fontweight','bold');
    get(gca,'position');
    a = axes('position',[0.22 0.15 0.6 0.03]); 
    % image(linspace(-maxFval,maxFval,size(jmap,1)),1, shiftdim(jmap,-1));
    set(gca,'ytick',[],'yticklabel',[],'xtick',linspace(fix(-maxFval),fix(maxFval),3),...
        'xticklabel',{sprintf('%d<',fix(-maxFval)),'0',sprintf('>%d',fix(maxFval))},'fontweight','bold');
    %imwrite(img2,map2,sprintf('rh.contrast_%s.jpg',results.Contrasts{i}),'jpeg','quality',100);
    imgfile = sprintf('rh.contrast_%s.jpg',results.Contrasts{i});
    print('-djpeg99',imgfile);
    roi_autocropimg(imgfile);
end

%delete(imgh)
%print('test01.gif','-djpeg');
