function H = sap_getcontour2(H)

fname = sprintf('corr_%s',H.fname);
V1 = spm_vol(fname);
H.Data1 = uint16(spm_read_vols(V1));
H.Data1 = H.Data1(end:-1:1,:,:);

H.mask = double(H.mask(end:-1:1,:,:));
H.mask = H.mask/max(H.mask(:));

for i=1:size(H.mask,2),
   mask = squeezeu8(H.mask(:,i,:)>0);
   mask = double(bwmorph(mask,'dilate',5));
   mask2(:,i,:) = mask;
end

data2 = double(H.Data1).*double(H.mask);
data3 = double(H.Data1).*double(mask2);

maxd2 = max(data2(:));
cutoff = 0; %500;
maxval = ceil(maxd2);
[h,x] = hist(data2(find(data2(:)>cutoff)),maxval);
Nb = 3;
N = length(h);
f = convn(h,hamming(14),'same');
beta0 = [ones(Nb,1)/Nb,linspace(1,N,Nb)',4*ones(Nb,1)];
[beta,g]=sap_gmem(1:N,f,beta0);
beta = sortrows(beta,2);
csfmean = round(beta(1,2));
csfvar  = round(beta(1,3));
gmean   = round(beta(2,2));
gvar    = round(beta(2,3));
wmean   = round(beta(3,2));
wvar    = round(beta(3,3));
[y,idx] = min(g(csfmean:gmean));
cutoff = maxd2*(csfmean+idx)/maxval;
cutoff1 = maxd2*round(mean([csfmean gmean]))/maxval;
cutoff2 = maxd2*round(csfmean+sqrt(csfvar))/maxval;
[y,idx] = min(g(gmean:wmean));
gwif  = maxd2*(gmean+idx)/maxval;
gwif1 = maxd2*round(mean([gmean wmean])+1)/maxval;
gwif2 = maxd2*round(wmean-sqrt(wvar))/maxval;

H.segment(size(H.Data1,2)).ptlist = {};
hfig = figure('Tag','contourfig','Doublebuffer','on','units','normalized','Position',[0.1 0.2 0.3 0.3]);
colormap gray;

hproc = waitbar(0,'Getting outlines','units','normalized','Position',[0.1 0.1 0.35 0.1]);
for i=1:size(data3,2);
    figure(hfig);
    img = squeeze(data3(:,i,:))';
    cla;
    imagesc(img);axis square;
    H.segment(i).lines = {};
    hold on;
    [C,h] = contour(img>=cutoff & img<=gwif,[1 1],'r');
    %contour(img>=gwif2,[1 1],'r');
    drawnow;
    for j=1:length(h),
        H.segment(i).lines{j}.ptlist = [get(h(j),'xdata');get(h(j),'ydata')]';
    end;
    H.segment(i).gval = gwif;
    waitbar(i/size(data2,2),hproc);
%    for k=1:500,refresh;end;
end;
close(hproc);

close;