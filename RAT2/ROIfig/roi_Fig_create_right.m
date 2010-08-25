function [img2,map2,maxFval,jmap] = roi_Fig_create_right(results,contrastlist,idlist,jmap,significance,drawbar,mask_con,mask_sig)

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
if nargin<7,
  mask_con = [];
end
if mask_con & nargin<8,
  mask_sig=.05;
end


%load Results_9_16_03.mat;

% Hack for filling in MC
id1 = find(strcmp(results.title{1},'RightdMC'));
id2 = find(strcmp(results.title{1},'RightvMC'));
if isempty(id2) | isempty(id1),
    disp('Substituting MC with PMC');
    id1 = find(strcmp(results.title{1},'RightpdPMC'));
    id2 = find(strcmp(results.title{1},'RightvPMC'));
    results.F(end+1,:) = results.F(id1,:);
    results.F(end+1,:) = results.F(id2,:);
    results.mean(end+1,:) = results.mean(id1,:);
    results.mean(end+1,:) = results.mean(id2,:);
    results.p(end+1,:) = results.p(id1,:);
    results.p(end+1,:) = results.p(id2,:);
    results.title{1}{end+1} = 'RightdMC';
    results.title{1}{end+1} = 'RightvMC';
end

%results.ROI_ids(end+1) = id1;
%results.ROI_ids(end+1) = id2;

[l,i] = sap_getLabels;
try,
for i=1:length(results.title{1}),
    ROI_idx(i,1) = find(strcmp(l,results.title{1}{i}));
end;
results.ROI_ids = ROI_idx;
catch,
    results.ROI_ids(end+1) = id1;
    results.ROI_ids(end+1) = id2;
end

results.Contrasts = results.title{2}';

idx = find(results.p(:)<=significance);

% Plotting significance
maxFval = mean(abs(results.mean(idx)))+std(abs(results.mean(idx)));
%maxFval = mean(abs(results.mean(idx)));
%maxFval = max(abs(results.mean(idx)));
%maxFval = min(max(abs(results.F(:))),15);
load rh_data;

[img,map] = imread('Right_Cereb_detached.tif'); 
[img,map] = cmunique(img,map);

%map = map(1:(double(max(img(:)))+1),:);

for i=contrastlist,
    significance = FDRcorrect(results.p(:,i),0.05,0);
    if isempty(significance)
        fprintf('no FDR threshold: contrast %02d\n',i);
        significance = 0.05;
    end
    
    ind=find(results.p(:,i)<=significance);
    if mask_con,
      mask_ind = find(results.mean(:,mask_con)>0 & ...
                     results.p(:,mask_con)<=mask_sig); 
      ind=intersect(ind,mask_ind);
    end
    PUids = results.ROI_ids(ind);
    rightids= find(PUids<32000);

    PUrightids=PUids(rightids);
    
    F = results.mean(ind,i);

    Fright= F(rightids);
    rhpatchid = find([rh(:).done]');
    
    ids2draw = intersect(rhpatchid,PUrightids);
    ids2draw = intersect(ids2draw,idlist);

    count = 0;
    p = {};
    img1 = zeros(size(img));
    for pu = ids2draw(:)',
        val = round(64.5+64*min(max(Fright(find(PUrightids==pu))/maxFval,-1),1));
        actcol = jmap(val,:);
        count = count+1;
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
        title(sprintf('%s[p%0.1g] masked by %s[p%0.1g] RH',results.Contrasts{i},...
            significance,results.Contrasts{mask_con},mask_sig),'fontsize',10,'fontweight','bold');
    else
      title(sprintf('%s[p%0.1g]',results.Contrasts{i},significance),'fontsize',10,'fontweight','bold');
    end
    
    get(gca,'position');
    
    % draw colorbar
    if drawbar
        a = axes('position',[0.22 0.15 0.6 0.03]); 
        image(linspace(-maxFval,maxFval,size(jmap,1)),1, shiftdim(jmap,-1));
        set(gca,'ytick',[],'yticklabel',[],'xtick',linspace(-maxFval,maxFval,3),...
            'xticklabel',{sprintf('%2.2f<',-maxFval),'0',sprintf('>%2.2f',maxFval)},'fontweight','bold');
    end
    %imwrite(img2,map2,sprintf('rh.contrast_%s.jpg',results.Contrasts{i}),'jpeg','quality',100);
    if mask_con,
      imgfile =sprintf('%s[p%0.1g]_masked_by_%s[p%0.1g]_RH.tif',results.Contrasts{1},...
          significance,results.Contrasts{mask_con},mask_sig);
    else
      imgfile = sprintf('%s[p%0.1g]_RH.tif',results.Contrasts{i},significance);
    end;
    print('-dtiff','-r300',imgfile);
    roi_autocropimg(imgfile,'tiff');
end

%delete(imgh)
%print('test01.gif','-djpeg');
