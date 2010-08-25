% spm_ROI_plot_charact Plot spatial characterization of regional effects
%
% spm_ROI_plot_charact(region) where region is a string with an ROI name
% (or a numeric index to a region) will plot the spatial profile of 
% activation for this region for all contrasts defined in the analysis
%
% spm_ROI_plot_charact(region,Contrast) will plot only the contrasts indexed
% by the variable Contrast (0 for all effects, 1 to n for each
% contrast defined in the analysis)
%
% spm_ROI_plot_charact(region,Contrast,Level2Contrast)
% where Contrast_Subject is a [numberofsubjects x 1] vector
% will weight each subject information by the corresponding
% element in Contrast_Subject (default all ones)
%

% 03/02
% alfnie@bu.edu

function spm_ROI_plot_charact(region, Contrast, Level2Contrast, gui);
if nargin<4, gui=0; end

INTERP=0;   % 0 does not interpolate; 1 interpolates images
FACT=8;
SCALE=FACT*100/(2*pi);
SMOOTH=hamming(FACT*2+1)*hamming(FACT*2+1)'; SMOOTH=SMOOTH/sum(SMOOTH(:));
SMOOTH2=hamming(FACT*2+1)*hamming(FACT*2+1)'; SMOOTH2=shiftdim(SMOOTH2/sum(SMOOTH2(:)),-1);
WRAP=FACT*4;
INVERT=0;
Tri=[imag(exp(j*linspace(0,2*pi,4)')),real(exp(j*linspace(0,2*pi,4)'))];

Label = sap_getLabels;
if ischar(region), nregion=[]; for n1=1:size(region,1), nregion=[nregion, strmatch(deblank(region(n1,:)),Label,'exact')]; end; if length(nregion)~=size(region,1), disp(strvcat(Label{nregion})); error('region name mismatch'); return; end;
else, nregion=region; region=strvcat(Label{nregion}); end
if isempty(nregion), return; end

% Find subject directories
path_subject=spm_ROI_input('files.path_subject'); 
nsubs=length(path_subject); 
ContrastSpatial=spm_ROI_input('model.ContrastSpatialVector');
Cnames=spm_ROI_input('model.ContrastName');
ncons=length(Cnames); 
Level2Cnames=spm_ROI_input('model.Level2ContrastName');
Level2Design=spm_ROI_input('model.Level2DesignMatrix');
Level2ncons=length(Level2Cnames); 
if nargin<3, Level2Contrast=1; end

if length(Level2Contrast)>1, 
    CONTRAST_SUBJ=Level2Contrast, 
else, 
    temp=spm_ROI_input('model.Level2ContrastVector');
    CONTRAST_SUBJ=Level2Design*temp{Level2Contrast}'; 
end

%CONTRAST_SUBJ = [1 0 0 0 0 0 0 0 0]';
%sidx = find(CONTRAST_SUBJ(:)');
sidx = 1:nsubs;

if nargin<2 | isempty(Contrast), Contrast=1:ncons; end

if gui,
    if length(nregion)>1,
        [opt,ok]=listdlg(...
            'ListString',...
            {Label{nregion}},...
            'SelectionMode', 'multiple',...
            'ListSize',[160,300],...
            'Name', 'spm_ROI',...
            'PromptString', 'Select the desired region');
        nregion=nregion(opt);
        region=strvcat(Label{nregion});
    end
    if length(Contrast)>1,
        [opt,ok]=listdlg(...
            'ListString',...
            {Cnames{Contrast}},...
            'SelectionMode', 'multiple',...
            'ListSize',[160,200],...
            'Name', 'spm_ROI',...
            'PromptString', 'Select the desired contrast(s)');
        Contrast=Contrast(opt);
    end
end

Contrast=sort(Contrast);

% Get stats for the region
if length(Level2Contrast)>1, Results=spm_ROI_compute_stats(1,nregion,Contrast,'random',1);
else, Results=spm_ROI_compute_stats(1,nregion,Contrast,'random',Level2Contrast); end
F=Results.conAll.regional.test.F;
Fp=Results.conAll.regional.test.p;
if length(Level2Contrast)>1, Results=spm_ROI_compute_stats(3,nregion,Contrast,'random',1);
else, Results=spm_ROI_compute_stats(3,nregion,Contrast,'random',Level2Contrast); end
T=Results.conAll.spatial.test.F;
Tp=Results.conAll.spatial.test.p;

xyz=cell([nsubs,1]);
AxisDir=0; xtemp=[]; ytemp=[];
Profile=cell([nsubs,ncons]);
Identity=cell([nsubs,1]);
minxyz=inf*ones(2,1); maxxyz=-inf*ones(2,1); meanxyz=zeros(2,1);
for nsub=sidx(:)',
    dataXYZ=[]; dataXYZCart=[];
    % reads XYZ position and spatial profile for each contrast
    for nroi=1:length(nregion),
        filename=[path_subject{nsub},filesep,'ROIdata_',num2str(nregion(nroi)*(~strcmp(Label{nregion(nroi)},'Global')),'%05d'),'.stat.mat'];
        dirnames=dir(filename); 
        if isempty(dirnames), disp(['Subject ',num2str(nsub),' does not contain info on region']); end
        datatemp=load(filename,'-mat');
        if isempty(datatemp.Stat), disp(['Subject ',num2str(nsub),' does not contain stats on region']); end
        if size(datatemp.XYZ,1)==3,
            if nsub==sidx(1), 
		if gui,
                [opt,ok]=listdlg(...
                    'ListString',...
                    {'x-y','x-z','y-z'},...
                    'SelectionMode', 'single',...
                    'ListSize',[160,40],...
                    'Name', 'spm_ROI',...
                    'PromptString', ['Select the desired' ...
		    ' projection']);
		else, opt=1; end
                SphBase=cat(3,[1,0,0;0,1,0],[1,0,0;0,0,1],[0,1,0;0,0,1])*pi/200;
                SphBase=SphBase(:,:,opt);
            end
            datatemp.XYZ=SphBase*datatemp.XYZ;
        end
        dataXYZ=[dataXYZ,datatemp.XYZ];
        dataXYZCart=[dataXYZCart,datatemp.XYZCart];
        Identity{nsub}=[Identity{nsub},nroi*ones(1,size(datatemp.XYZ,2))];
        if length(Contrast)>1,
            Profile{nsub,1}=[Profile{nsub,1},sqrt(sum(abs(datatemp.Stat.conAll.profiles.spatial(Contrast,:)).^2,1))]; 
        else,
            Profile{nsub,1}=[Profile{nsub,1},datatemp.Stat.con(Contrast).profiles.spatial]; 
        end
    end
    if nsub==sidx(1), centerdataXYZ=angle(sum(exp(j*dataXYZ),2)); end
    dataXYZ=SCALE*(repmat(centerdataXYZ,[1,size(dataXYZ,2)])+angle(exp(j*(dataXYZ-repmat(centerdataXYZ,[1,size(dataXYZ,2)])))));
    xyz{nsub}=dataXYZ-repmat(mean(dataXYZ,2),[1,size(dataXYZ,2)]);
    meanxyz=meanxyz+mean(dataXYZ,2);
    minxyz=floor(min(minxyz,min(xyz{nsub},[],2)));
    maxxyz=ceil(max(maxxyz,max(xyz{nsub},[],2)));
    xtemp=[xtemp,xyz{nsub}];
    ytemp=[ytemp,(dataXYZCart-repmat(mean(dataXYZCart,2),[1,size(dataXYZCart,2)]))];
end
AxisDir=xtemp*pinv(ytemp);

meanxyz=meanxyz/nsubs;
sH=[maxxyz-minxyz+1+2*WRAP]';
H=zeros([sH]); n=H; 
nid=zeros([length(nregion),sH]);
for nsub=sidx(:)',
    xyznsub=WRAP+1+floor(xyz{nsub}-repmat(minxyz,[1,size(xyz{nsub},2)]));
    idx=sub2ind(sH,xyznsub(1,:),xyznsub(2,:));
    for nroi=1:length(nregion),
        ididx=find(Identity{nsub}==nroi);
        for n1=1:length(ididx), nid(nroi,idx(ididx(n1)))=nid(nroi,idx(ididx(n1)))+1; end
    end
    for n1=1:length(idx), H(idx(n1))=H(idx(n1))+CONTRAST_SUBJ(nsub)*real(Profile{nsub,1}(n1)); end
    for n1=1:length(idx), n(idx(n1))=n(idx(n1))+abs(CONTRAST_SUBJ(nsub)); end
end

nid=convn(nid/nsubs,SMOOTH2,'same');
if length(Level2Contrast)>1 || 0, % select the best matching subject for plotting
   if length(Level2Contrast)>1, [nill,nsub]=max(Level2Contrast); 
   else,
      nidwin=zeros(1,prod(size(sidx)));
      [nill,t]=max(nid,[],1);
      for nsub=sidx(:)', % find winning subject for plotting roi contour
          xyznsub=WRAP+1+floor(xyz{nsub}-repmat(minxyz,[1,size(xyz{nsub},2)]));
          idx=sub2ind(sH,xyznsub(1,:),xyznsub(2,:));
          nidwin(nsub)=length(find(Identity{nsub}==t(idx)));
      end
      [nill,nsub]=max(nidwin);
   end
xyznsub=WRAP+1+floor(xyz{nsub}-repmat(minxyz,[1,size(xyz{nsub},2)]));
idx=sub2ind(sH,xyznsub(1,:),xyznsub(2,:));
nid(:)=0;
for nroi=1:length(nregion),
   ididx=find(Identity{nsub}==nroi);
   for n1=1:length(ididx), nid(nroi,idx(ididx(n1)))=nid(nroi,idx(ididx(n1)))+1; end
end
nid=convn(nid,SMOOTH2,'same');
end


idx=find(n);
H(idx)=H(idx)./n(idx);
%H=H.*min(1,4*n/mean(n(:)));
AxisDir=AxisDir/max(sqrt(sum(abs(AxisDir).^2,1)));

% H [sH] average spatial profile 
% nid [nregions,sH] for each region proportional to # of subjects overlapping

% Plots
figure('units','norm','position',[.1,.1,.8,.8],'name',['spm_ROI. Characterization of contrast ',strcat(Cnames{Contrast})],'numbertitle','off','color',[.1,0,.1]);
map=hot; map(:,3)=0; map=map(1:ceil(size(map,1)*3/4),:); map=[flipud(map(1:end,[3,2,1]));(map(1:end,:))]; 
if INVERT, map=flipud(map); end
colormap(map);
nid1=nid; 
[nill,roi1]=max(nid>0,[],1); roi1(find(nill<.005))=0; roi1=shiftdim(roi1,1); roi1=ordfilt2(roi1,3,ones([2,2]));
Hcon=convn(H,SMOOTH,'same');


h=Hcon;
if INTERP,
    idx=find(h(:));
    [x,y]=ind2sub(size(h),idx);
    [X,Y]=ndgrid(1:size(h,1),1:size(h,2));
    h=griddata(x,y,h(idx),X,Y);
end
%idxnull=find(~roi1(:) | abs(h(:))<max(abs(h(:)))/8);
%h(idxnull)=nan;
nid1(2,:,:)=nid1(2,:,:)*.7;
ax1=axes('units','norm','position',[.075,.2,.6,.6]); color=get(gca,'colororder'); color=repmat(color,[16,1]);
surface(h'); shading interp; hold on;
if 1, 
   for n1=1:length(nregion), 
      t=nid1(n1,:,:); 
      t=convn(shiftdim(t==max(nid1,[],1) & t>=1/2*mean(t(find(t)))),SMOOTH,'same'); 
      %t=convn(shiftdim(t==max(nid1,[],1)),SMOOTH,'same'); 
      [nill,h0]=contour('v6',(1:sH(1)),(1:sH(2)),max(h(:))*(1+t'),max(h(:))*(1+[1/2,1/2])); 
      set(h0,'linewidth',2,'edgecolor',color(n1,:)); 
      for n2=1:length(h0), set(h0(n2),'zdata',2*max(abs(h(:)))*ones(length(get(h0(n2),'xdata')),1)); end; 
      %for n2=1:length(h0), set(h0(n2),'zdata',2*max(abs(h(:)))*ones(size(get(h0(n2),'zdata')))); end; 
      hold on; 
   end; 
else, for n1=1:length(nregion), t=double(ordfilt2(shiftdim(nid1(n1,:,:),1),13,ones(5,5))>0); [nill,h0]=contour((1:sH(2)),(1:sH(1)),max(h(:))*(1+t'/max(t(:))),max(h(:))*(1+[1/2,1/2])); set(h0,'linewidth',2,'edgecolor',color(n1,:)); hold on; end; end
mh=[sum(sum(abs(h(1:ceil(sH(1)/2),1:ceil(sH(2)/2))))),sum(sum(abs(h(1:ceil(sH(1)/2),ceil(sH(2)/2)+1:sH(2)))));sum(sum(abs(h(ceil(sH(1)/2)+1:sH(1),1:ceil(sH(2)/2))))),sum(sum(abs(h(ceil(sH(1)/2)+1:sH(1),ceil(sH(2)/2)+1:sH(2)))))]';
[nill,idxmh]=min(mh(:)); [idxmh1,idxmh2]=ind2sub([2,2],idxmh); mH=[1/8*sH(1)+6/8*(idxmh2-1)*sH(1), 1/8*sH(2)+6/8*(idxmh1-1)*sH(2)];
%%%%plot3(mH(1)+[0;1]*min(sH)/8*AxisDir(1,:), mH(2)+[0;1]*min(sH)/8*AxisDir(2,:), 2*max(h(:))*ones(2,size(AxisDir,2)), 'r-','linewidth',2);
%%%%patch(mH(1)+min(sH)/8*ones(size(Tri,1),1)*AxisDir(1,:)+min(sH)/32*(Tri*[-AxisDir(2,:);AxisDir(1,:)]), mH(2)+min(sH)/8*ones(size(Tri,1),1)*AxisDir(2,:)+min(sH)/32*(Tri*[AxisDir(1,:);AxisDir(2,:)]), 2*max(h(:))*ones(size(Tri,1),size(AxisDir,2)),'r');
%%%%h0=text(mH(1)+1.5*min(sH)/8*AxisDir(1,:), mH(2)+1.5*min(sH)/8*AxisDir(2,:),strvcat('X','Y','Z')); set(h0,'backgroundcolor','w','fontweight','bold','fontsize',16,'horizontalalignment','center'); 
hold off;
h0=xlabel('theta'); set(h0,'fontweight','bold','color','y','fontsize',24); h0=ylabel('phi'); set(h0,'fontweight','bold','color','y','fontsize',24);
axis equal; set(gca,'color','k','ydir','normal','xticklabel',[],'yticklabel',[],'xlim',[1,sH(1)],'ylim',[1,sH(2)],'clim',max(abs(h(:)))*[-1,1],'dataaspectratio',[1,1,.01]); drawnow;
hc=colorbar; set(hc,'xcolor','r','ycolor','r','units','norm'); pos=get(hc,'position'); set(hc,'position',[pos(1:2),.5*pos(3),pos(4)],'yaxislocation','left'); % axes(hc); h0=ylabel('Activation'); set(h0,'fontweight','bold');
set(gcf,'color','k');

ax3=axes('units','norm','position',[.7,.2,.225,.6]);
for n1=1:length(nregion), 
    if length(Contrast)>1, temp='Multiple contrasts'; else, temp=Cnames{Contrast}; end
    h=text(0,n1,...
	   strvcat(region(n1,:),...
		   ['Regional contrast ',temp],...
            ['F=',num2str(F(n1),'%8.4f'),'  p=',num2str(Fp(n1),'%5.4f')],...
		   ['Spatial Contrast ''',ContrastSpatial,''''],...
		   ['F=',num2str(T(n1),'%8.4f'),'  p=',num2str(Tp(n1),'%5.4f')])); 
    set(h,'horizontalalign','left','fontsize',8,'fontweight','bold','color',color(n1,:)); 
end; 
set(ax3,'ydir','reverse','xtick',[],'ytick',[],'box','off','color',[.1,0,.1]); 
axis([-.5,5,0,length(nregion)+1]);
