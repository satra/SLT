function [img2,map2,maxFval,jmap] = roi_Fig_create_left(results,contrastlist,idlist,jmap,significance,drawbar,mask_con,mask_sig)

if ischar(results),
    load(results);
end
if nargin<2 | isempty(contrastlist),
    contrastlist = [1:size(results.p,2)];
end
if nargin<3 | isempty(idlist),
    idlist = 1:65535;
end
if nargin<4 | isempty(jmap),
    load rbmap;
    jmap =rbmap;
    %load bwmap.mat;
    %jmap = bwmap;
end;
if nargin<5 | isempty(significance),
    significance = 0.05;
end
if nargin<6 | isempty(drawbar),
    drawbar = 1;
end
if nargin<7 | isempty(mask_con),
  mask_con = [];
end
if mask_con & nargin <8,
  mask_sig=.05;
end
  

% Hack for filling in MC
id1 = find(strcmp(results.title{1},'LeftdMC'));
id2 = find(strcmp(results.title{1},'LeftvMC'));
if isempty(id2) | isempty(id1),
    disp('Substituting MC with PMC');
    id1 = find(strcmp(results.title{1},'LeftpdPMC'));
    id2 = find(strcmp(results.title{1},'LeftvPMC'));
    results.F(end+1,:) = results.F(id1,:);
    results.F(end+1,:) = results.F(id2,:);
    results.mean(end+1,:) = results.mean(id1,:);
    results.mean(end+1,:) = results.mean(id2,:);
    results.p(end+1,:) = results.p(id1,:);
    results.p(end+1,:) = results.p(id2,:);
    results.title{1}{end+1} = 'LeftdMC';
    results.title{1}{end+1} = 'LeftvMC';
end

[l,i] = sap_getLabels;
try
for i=1:length(results.title{1}),
    ROI_idx(i,1) = find(strcmp(l,results.title{1}{i}));
end;
results.ROI_ids = ROI_idx;
catch
    results.ROI_ids(end+1) = id1;
    results.ROI_ids(end+1) = id2;
end
results.Contrasts = results.title{2}';

%significance = 0.05;
idx = find(results.p(:)<=significance);
maxFval = mean(abs(results.mean(idx)))+std(abs(results.mean(idx)));
%maxFval = mean(abs(results.mean(idx)));
%maxFval = min(abs(results.F(idx)));

%maxFval = min(max(abs(results.F(:))),15);
load lh_data;

%load bwmap;
%jmap=bwmap;

[img,map] = imread('Left_Cereb_detached.tif'); 
[img,map] = cmunique(img,map);

for i=contrastlist,
    significance = FDRcorrect(results.p(:,i),0.05,0);
    if isempty(significance)
        fprintf('no FDR threshold: contrast %02d\n',i);
        significance = 0.05;
    end
    
    ind=find(results.p(:,i)<=significance);
    %%%%%Jason added 2/21/06, can now mask contrast with baseline%%%%
    %%%%%contrast results%%%%%
    if mask_con,
      mask_ind = find(results.mean(:,mask_con)>0 & ...
                     results.p(:,mask_con)<=mask_sig); 
      ind=intersect(ind,mask_ind);
    end
    PUids = results.ROI_ids(ind);
    leftids = find(PUids>32000);
    %rightids= find(PUids<32000);
    PUleftids=PUids(leftids)-32000;
    %PUrightids=PUids(rightids);
    
    F = results.mean(ind,i);
    
    Fleft = F(leftids);
    %Fright= F(rightids);
    
    
    lhpatchid = find([lh(:).done]');
    
    ids2draw = intersect(lhpatchid,PUleftids);
    ids2draw = intersect(ids2draw,idlist);
    count = 0;
    p = {};
    img1 = zeros(size(img));
    for pu = ids2draw(:)',
        val = round(64.5+64*min(max(Fleft(find(PUleftids==pu))/maxFval,-1),1));
        actcol = jmap(val,:);
        count = count+1;
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
    whiteidx = find(sum(map,2)==3)-1;
    rgb1 = ind2rgb(imgb,map);

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
    
    %%%%Jason added check for masking contrast addition to title 2/21/06
    if mask_con,
        title(sprintf('%s[p%0.1g] masked by %s[p%0.1g] LH',results.Contrasts{i},...
            significance,results.Contrasts{mask_con},mask_sig),'fontsize',10,'fontweight','bold');
    else
      title(sprintf('%s[p%0.1g]',results.Contrasts{i},significance),'fontsize',10,'fontweight','bold');
    end
    % draw colorbar
    if drawbar
        a = axes('position',[0.22 0.15 0.6 0.03]); 
        image(linspace(-maxFval,maxFval,size(jmap,1)),1, shiftdim(jmap,-1));
        set(gca,'ytick',[],'yticklabel',[],'xtick',linspace(-maxFval,maxFval,3),...
            'xticklabel',{sprintf('%2.2f<',-maxFval),'0',sprintf('>%2.2f',maxFval)},'fontweight','bold');
    end
    %imwrite(img2,map2,sprintf('lh.contrast_%d.jpg',i),'jpeg','quality',100);
    if mask_con,
      imgfile =sprintf('%s[p%0.1g]_masked_by_%s[p%0.1g]_LH.tif',results.Contrasts{1},...
          significance,results.Contrasts{mask_con},mask_sig);
    else
      imgfile = sprintf('%s[p%0.1g]_LH.tif',results.Contrasts{i},significance);
    end;
    %imgfile = sprintf('lh.%03d.contrast_%s.jpg',i,results.Contrasts{i});
    print('-dtiff','-r300',imgfile);
    roi_autocropimg(imgfile,'tiff');
end

%delete(imgh)
%print('test01.gif','-djpeg');
