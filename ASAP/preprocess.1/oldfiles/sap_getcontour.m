function H = sap_getcontour(H)

fname = sprintf('corr_%s',H.fname);
V1 = spm_vol(fname);
H.Data1 = uint16(spm_read_vols(V1));
H.Data1 = H.Data1(end:-1:1,:,:);

H.mask = H.mask(end:-1:1,:,:);
VW=spm_vol(sprintf('%s_seg2',H.fname));	% White matter
VWd = spm_read_vols(VW);
VWd = VWd(end:-1:1,:,:);
VG=spm_vol(sprintf('%s_seg1',H.fname));	% Gray matter
VGd = spm_read_vols(VG);
VGd = VGd(end:-1:1,:,:);


H.segment(size(H.Data1,2)).ptlist = {};
hfig = figure('Tag','contourfig','Doublebuffer','on','units','normalized','Position',[0.1 0.2 0.3 0.3]);
colormap gray;

hproc = waitbar(0,'Getting outlines','units','normalized','Position',[0.1 0.1 0.35 0.1]);
for n=1:size(H.Data1,2),
%for n=100:110,   
   img = squeezeu8(H.Data1(:,n,:))+ ...
      65535*double((squeeze(VWd(:,n,:)>0).*squeezeu8(H.mask(:,n,:)>0)));
   img = img';
   figure(hfig);
   imagesc(squeezeu8(H.Data1(:,n,:))');
   img = (img>65535);
   %hold on;
   %C = [];h = [];
   %[C,h] = contour(img,[1 1],'y');
   %hold off;
   %drawnow;
   %ct = 0;
   H.segment(n).lines = {};
   %for j=1:length(h),
   %   H.segment(n).lines{j}.ptlist = [get(h(j),'xdata');get(h(j),'ydata')]';
   %   ct = j;
   %end;
   mask = squeezeu8(H.mask(:,n,:)>0);
   mask = double(bwmorph(mask,'dilate',3));
   img1 = squeezeu8(H.Data1(:,n,:))+65535*(squeeze(VGd(:,n,:)>0.15).*mask);
   img1 = img1';
   imgg = (img1>65535);
   imgg = double(bwmorph(imgg,'dilate',2));
   imgg = imgg.*(img<1);
   gval = 1;
   hold on;
   [C,h] = contour(imgg,[gval gval],'g');
   hold off;
   drawnow;
   for j=1:length(h),
      H.segment(n).lines{j}.ptlist = [get(h(j),'xdata');get(h(j),'ydata')]';
   end;
   H.segment(n).gval = gval;
   waitbar(n/size(H.Data1,2),hproc);
end;
close(hproc);

H = rmfield(H,'Data1');
%savename =sprintf('c%s',matfname);
%save(savename,'H');
close;