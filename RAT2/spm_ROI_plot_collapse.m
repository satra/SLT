function spm_ROI_plot_collapse(varargin);

warning off MATLAB:divideByZero
opt=varargin;
header='spm_ROI. Characterization of contrast';
Fighdl=get(0,'children');
Fighdl=sort(Fighdl);
Figname=get(Fighdl,'name');
Figidx=strmatch(header,Figname);
if isempty(Figidx), display('First you must plot the results... use spm_ROI_plot_charact'); return; end
for n1=1:length(Figidx), Figname{Figidx(n1)}=Figname{Figidx(n1)}(length(header)+1:end); end
if nargin<1 | isempty(opt{1}),
    [opt{1},ok]=listdlg(...
        'ListString',...
        {Figname{Figidx}},...
        'SelectionMode', 'multiple',...
        'ListSize',[300,300],...
        'Name', 'spm_ROI. Collapse plots utility',...
        'PromptString', 'Select the desired results');
end
if isempty(opt{1}), return; end
if length(opt{1})<2, error('You must select more than one figure to collapse'); return; end
Figidx=Figidx(opt{1});

if length(opt{1})<=3,
    if nargin<2 | isempty(opt{2}),
        [opt{2},ok]=listdlg(...
            'ListString',...
            {'One color per result (categorical plot)',...
                'One color-channel per result (smooth plot)',...
                'Color-scale ordinal result (smooth plot)'},...
            'SelectionMode', 'single',...
            'ListSize',[300,300],...
            'Name', 'spm_ROI. Collapse plots utility',...
            'PromptString', 'Select type of plot');
    end
    if isempty(opt{2}), return; end
    TYPE=opt{2};
else,
    TYPE=1;
end

data=[];
for n1=1:length(Figidx),
    hh1=get(Fighdl(Figidx(n1)),'children');
    hh2=get(hh1(end),'children');
    hh3=get(hh2(end),'cdata');
    try, data=cat(3,data,hh3); catch, error('Result figures must contain the same ROIs'); return; end
end
if length(hh2)>9,
    hx=get(hh2(8:end-1),'xdata');
    hy=get(hh2(8:end-1),'ydata');
    hz=get(hh2(8:end-1),'zdata');
    hc=get(hh2(8:end-1),'cdata');
else,
    hx{1}=get(hh2(8:end-1),'xdata');
    hy{1}=get(hh2(8:end-1),'ydata');
    hz{1}=get(hh2(8:end-1),'zdata');
    hc{1}=get(hh2(8:end-1),'cdata');
end    
sdata=size(data);

switch(TYPE),
    case 1,
        Windata=cat(3,zeros(sdata(1:2)),data.^2);
        [nill,Winidx]=max(Windata,[],3);
        
        figure('units','norm','position',[.1,.1,.8,.8],'name',['spm_ROI. Collapse of contrasts ',strcat(Figname{Figidx})],'numbertitle','off','color',[.1,0,.1]);
        colormap hot;
        h1=axes('units','norm','position',get(hh1(end),'position')); 
        h2=imagesc(Winidx); shading interp; hold on; 
        set(h1,'ydir','normal','color','k','xtick',[],'ytick',[]);
        for n1=1:length(hx), plot3(hx{n1},hy{n1},hz{n1},'color','b','linewidth',2); end
        axis equal; axis off;
        I=colormap; I=I(ceil(linspace(1,size(I,1),sdata(3)+1)),:); I=I(2:end,:);
        
    case 2,
        Windata=cat(3,data,zeros([sdata(1:2),3-sdata(3)]));
        Windata=Windata.^2./repmat(sum(abs(Windata).^2,3),[1,1,3]);
        
        figure('units','norm','position',[.1,.1,.8,.8],'name',['spm_ROI. Collapse of contrasts ',strcat(Figname{Figidx})],'numbertitle','off','color',[.1,0,.1]);
        colormap hot;
        h1=axes('units','norm','position',get(hh1(end),'position')); 
        h2=image(Windata); shading interp; hold on; 
        set(h1,'ydir','normal','color',[.1,0,.1],'xtick',[],'ytick',[]);
        for n1=1:length(hx), plot3(hx{n1},hy{n1},hz{n1},'color','w','linewidth',2); end
        axis equal; axis off;
        I=eye(3);
    case 3,
        THR=.1;
        Windata=data; 
        %Windata(Windata~=0)=Windata(Windata~=0)-min(Windata(Windata(:)~=0));
        thr=THR*max(abs(Windata(Windata>0)));
        Windata=Windata.*repmat(any(Windata>thr,3),[1,1,sdata(3)]);
        Windata=reshape(reshape(Windata.^2./repmat(sum(abs(Windata).^2,3),[1,1,sdata(3)]),[prod(sdata(1:2)),sdata(3)])*[1:sdata(3)]',sdata(1:2));
        
        figure('units','norm','position',[.1,.1,.8,.8],'name',['spm_ROI. Collapse of contrasts ',strcat(Figname{Figidx})],'numbertitle','off','color','w');
        map=hot; map(:,3)=0; map=map(1:ceil(size(map,1)*3/4),:); map=[flipud(map(1:end,[3,2,1]));(map(1:end,:))]; map=[ones(1,3);map];  % color - scale
        %map=[.5*ones(1,3);gray(128)];  % gray - scale
	colormap(map);
        h1=axes('units','norm','position',get(hh1(end),'position')); 
        [a,b]=sort(Windata(:)); 
	c=reshape(linspace(1,size(map,1),prod(size(Windata))),size(Windata)); 
	d=zeros(size(Windata)); d(b)=c; d(isnan(Windata))=0;
        h2=imagesc(d); shading interp; hold on; 
        %set(h1,'clim',[1,sdata(3)]);
        set(h1,'ydir','normal','color','k','xtick',[],'ytick',[]);
        for n1=1:length(hx), plot3(hx{n1},hy{n1},hz{n1},'color','g','linewidth',2); end
        axis equal; axis off;
        I=colormap; I=I(2:end,:);
    end

if size(I,1)~=sdata(3), h5=colorbar; set(h5,'xtick',[],'ytick',[],'xcolor','w','ycolor','w','box','off'); end
for n1=1:3, h5=plot3(0,0,0); hdlcopy(hh2(4+n1),h5,{'xdata','ydata','zdata','linewidth','color'}); end
h5=patch; hdlcopy(hh2(4),h5,{'xdata','ydata','zdata','cdata','facecolor'});
for n1=1:3, h5=text(0,0,''); hdlcopy(hh2(n1),h5,{'position','string','fontweight','fontsize','backgroundcolor'}); end
hold off;

h3=axes('units','norm','position',get(hh1(1),'position'));
for n1=1:sdata(3),
    if size(I,1)==sdata(3), patch([0,0,1,1],4*(n1-1)+[0,1,1,0],I(n1,:)); end
    h4=text(2,4*(n1-1)+.5,Figname{Figidx(n1)}); set(h4,'fontweight','bold','fontsize',10,'color','b');
end
set(h3,'color',[.1,0,.1],'xtick',[],'ytick',[],'ylim',[0,(sdata(3)-1)*4+1],'xlim',[0,8]); axis off;

