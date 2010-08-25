% SPM_ROI_RESULTS Plot across-subject results of statistical analyses
%
% If called without arguments spm_ROI_results will prompt the user as needed.
% spm_ROI_results(opt1,opt2,...,opt6) will not prompt the user and take their answers from the input variables 
%   opt1  : Type of analysis done
%               1:  region-level test of multiple contrasts
%               2:  region-level test of specific contrast(s)
%               3:  spatial-level test of multiple contrasts
%               4:  spatial-level test of specific contrast(s)
%   opt2  : Vector of numeric indexes of regions to include in the analysis
%           (or, character array of region names)
%   opt3  : Vector of numeric indexes of 1st-level contrast to be included in the analysis
%   opt4  : Inter-subject analysis type
%               1:  fixed-effect analysis
%               2:  random-effect analysis
%   opt5  : Numeric index of 2nd-level contrast to be included in the analysis
%   opt6  : Plots grouping option (only used when multiple regions and multiple contrasts are selected)
%               1:  create one figure for each 1st-level contrast tested
%               2:  create one figure for each region tested
%
% Plots=spm_ROI_results(...) will output a structure containing all the results plotted
%


% 02/02
% alfnie@bu.edu

function [Plots,opt]=spm_ROI_results(varargin);

if nargin<1, opt=cell([6,1]); else opt=varargin; end
Plevels=[.05,.01,.001];			% p threshold(s) for bar plots
Pcolors=['b','g','y','r'];		% color(s) for bar plots
FIXEDRANDOM={'fixed','random'};
Label=sap_getLabels;
path_subject=spm_ROI_input('files.path_subject');
nsubs=length(path_subject);
ContrastName=spm_ROI_input('model.ContrastName');
Level2ContrastName=spm_ROI_input('model.Level2ContrastName');
ExperimentName=spm_ROI_input('files.name_experiment');
if ~isempty(ExperimentName), load(ExperimentName,'expt','-mat'); else, expt=[]; end

% Let the user decide some things

if isempty(opt{1}),
    [opt{1},ok]=listdlg(...
        'ListString',...
        {'See what regions respond to the experimental paradigm                             (REGION-level test of MULTIPLE contrasts)'...
            'See what regions respond to an specific contrast                                       (REGION-level test of SPECIFIC contrast(s))',...
            'See what regions show a spatial response to the experimental paradigm    (SPATIAL-level test of MULTIPLE contrasts)',...
            'See what regions show a spatial response to an specific contrast              (SPATIAL-level test of SPECIFIC contrast(s))'},...
        'SelectionMode', 'single',...
        'ListSize',[600,100],...
        'Name', 'spm_ROI',...
        'PromptString', 'Do you want to...');
end
if isempty(opt{1}), return; end
UserOption=opt{1};

if isempty(opt{2}),
    % Preselect only the regions that were analyzed
    Regions=zeros(length(Label),1);
    for nsub=1:nsubs,
        [dirnames,nill]=spm_list_files(path_subject{nsub},'ROIdata_?????.stat.mat'); 
        idxregions=sscanf(lower(dirnames'),'roidata_%05d.stat.mat'); 
        idxregions=idxregions(idxregions>0);
        if ~isempty(expt), idxregions=intersect(idxregions(:),expt.subject(nsub).roidata(1).PUlist(:)); end
        Regions(idxregions)=Regions(idxregions)+1;
    end
    idxRegions=find(Regions==nsubs);
    [labelRegions,idx]=sortrows(strvcat(Label{idxRegions}));
    idxRegions=idxRegions(idx);
    %spm_ROI_input('private.AvailableRegions',idxRegions);
    %idxRegions=spm_ROI_input('private.AvailableRegions');
    [opt{2},ok]=listdlg(...
        'ListString',...
        {Label{idxRegions}},...
        'SelectionMode', 'multiple',...
        'ListSize',[160,300],...
        'Name', 'spm_ROI',...
        'PromptString', 'Select the desired region(s)');
    if isempty(opt{2}), return; end
    opt{2}=idxRegions(opt{2});
else
    if ischar(opt{2}), 
        nregion=[]; 
        for n1=1:size(opt{2},1), nregion=[nregion, strmatch(deblank(opt{2}(n1,:)),Label,'exact')]; end; 
        opt{2}=nregion;
    end
    [labelRegions,idx]=sortrows(strvcat(Label{opt{2}}));
    opt2{2}=opt{2}(idx);
end
if isempty(opt{2}), return; end
idxRegions=opt{2};

if isempty(opt{3}),
    [opt{3},ok]=listdlg(...
        'ListString',...
        ContrastName,...
        'SelectionMode', 'multiple',...
        'ListSize',[160,200],...
        'Name', 'spm_ROI',...
        'PromptString', 'Select the desired 1st-level contrast(s)');
end
if isempty(opt{3}), return; end
Contrast=opt{3};

if isempty(opt{4}),
    [opt{4},ok]=listdlg(...
        'ListString',...
        {'Fixed-effects','Random-effects'},...
        'SelectionMode', 'single',...
        'ListSize',[160,40],...
        'Name', 'spm_ROI',...
        'PromptString', 'Inter-subject analysis type?');
end
if isempty(opt{4}), return; end
FixedRandom=FIXEDRANDOM{opt{4}};

if isempty(opt{5}),
    [opt{5},ok]=listdlg(...
        'ListString',...
        Level2ContrastName,...
        'SelectionMode', 'single',...
        'ListSize',[160,200],...
        'Name', 'spm_ROI',...
        'PromptString', 'Select the desired 2nd-level contrast(s)');
end
if isempty(opt{5}), return; end
Level2Contrast=opt{5};

% Do inter-subject analyses
[RESULTS,valid]=spm_ROI_compute_stats(UserOption,idxRegions,Contrast,FixedRandom,Level2Contrast);
idxRegions=idxRegions(valid);

% Prepare data for plots

switch UserOption,
case 1, %region-level test of multiple effects
    Plots.title0='region-level test';
    Plots.xlabel='F';
    Plots.title{2}={'Multiple effects'};
    RESULTS=RESULTS.conAll.regional;
    temp=[repmat(strvcat(ContrastName{Contrast}),[size(RESULTS(1).data.h,4),1]), repmat(' eig',[size(RESULTS(1).data.h,4)*length(Contrast),1]), num2str(ceil((1:size(RESULTS(1).data.h,4)*length(Contrast))'/length(Contrast)))];
    Plots.legend{1}=mat2cell(temp,ones(size(temp,1),1));
case 2, %region-level test of a contrast on the effects
    Plots.title0='region-level test';
    Plots.xlabel='F';
    Plots.title{2}={ContrastName{Contrast}};
    RESULTS=[RESULTS.con(Contrast).regional];
    for n1=1:length(Contrast),
        temp=[repmat(strvcat(ContrastName{Contrast(n1)}),[size(RESULTS(1).data.h,4),1]), repmat(' eig',[size(RESULTS(1).data.h,4),1]), num2str(ceil((1:size(RESULTS(1).data.h,4))'))];
        Plots.legend{n1}=mat2cell(temp,ones(size(temp,1),1));
    end
case 3, %spatial-level test of multiple effects
    Plots.title0='spatial-level test';
    Plots.xlabel='F';
    Plots.title{2}={'Multiple effects'};
    RESULTS=RESULTS.conAll.spatial;
    Plots.legend{1}={ContrastName{Contrast}};
case 4, %spatial-level test of a contrast on the effects
    Plots.title0='spatial-level test';
    Plots.xlabel='T';
    Plots.title{2}={ContrastName{Contrast}};
    RESULTS=[RESULTS.con(Contrast).spatial];
    Plots.legend=[];
end
Plots.title{3}={Level2ContrastName{Level2Contrast}};

temp=[RESULTS(:).test];
Plots.F=permute(cat(3,temp(:).F),[1,3,2]);   % regions x level1 contrast x level2 contrast test statistics
Plots.p=permute(cat(3,temp(:).p),[1,3,2]);   % regions x level1 contrast x level2 contrast test significance
temp=[RESULTS(:).data];
Plots.mean=permute(real(cat(3,temp(:).h)),[1,3,2,4]); % regions x level1 contrast x level2 contrast x eigenvariates matrix of effects
if UserOption~=4, Plots.conf=nan*ones(size(Plots.mean)); 
else, Plots.conf=permute(real(cat(3,temp(:).h_conf)),[1,3,2,4]); end

idx=find(all(all(~isnan(Plots.p),2),3)); 
if isempty(idx), 
    errordlg(['Unable to compute the results - unsufficient degrees of freedom - minimum number of subjects = ',num2str(nsubs+1-min(RESULTS(1).test.dof{end}(:)))],'spm_ROI. Error','replace'); 
    return; 
end
idxRegions=idxRegions(idx);
Plots.mean=Plots.mean(idx,:,:,:);
Plots.conf=Plots.conf(idx,:,:,:);
Plots.F=Plots.F(idx,:,:);
Plots.p=Plots.p(idx,:,:);
Plots.title{1}={Label{idxRegions}};

sPlots=size(Plots.F);
if sum(sPlots>1)==1, [nill,opt{6}]=find(sPlots>1); % 1 regions, 2 1st-level contrast, 3 2nd-level contrast
elseif isempty(opt{6}),
[opt{6},ok]=listdlg(...
    'ListString',...
    {['for each contrast',' (', num2str(sPlots(1)),')'],...
        ['for each region',' (', num2str(sPlots(2)),')']},...
    'SelectionMode', 'single',...
    'ListSize',[160,60],...
    'Name', 'spm_ROI',...
    'PromptString', 'Create a different figure ');
end

Group=opt{6};
Plots.mean=permute(Plots.mean,[Group,setdiff(1:4,Group)]);
Plots.conf=permute(Plots.conf,[Group,setdiff(1:4,Group)]);
Plots.F=permute(Plots.F,[Group,setdiff(1:3,Group)]);
Plots.p=permute(Plots.p,[Group,setdiff(1:3,Group)]);
Plots.title={Plots.title{[Group,setdiff(1:3,Group)]}};
Plots.opt = opt;

%%%%%%%%%%%%%%%%%%%%%%% PLOTS %%%%%%%%%%%%%%%%%%
for nplot2=1:size(Plots.F,2),
    for nplot3=1:size(Plots.F,3),
        figure('numbertitle','off','name','spm_ROI results window','color',[.5,0,.5]);
        hd=subplot(131);%set(hd,'units','normalized','position',[.2,.6,.4,.3]);
        % Plots effects
        if UserOption==4 | UserOption==2, nplot2temp=nplot2; else, nplot2temp=':'; end
        temp=squeeze(Plots.mean(:,nplot2temp,nplot3,:));
        bar(1:size(Plots.mean,1),temp(:,:)); 
        if UserOption==4,
            hold on;
            hd=errorbar(1:size(Plots.mean,1),Plots.mean(:,nplot2,nplot3),Plots.conf(:,nplot2,nplot3),'r.'); set(hd,'markersize',16,'linewidth',2);
            hold off;
            set(gca,'xlim',[0,size(Plots.mean,1)+1],'ylim',max(abs(Plots.mean(:,nplot2,nplot3))+abs(Plots.conf(:,nplot2,nplot3)))*[-1.1,1.1]);
        else    
            set(gca,'xlim',[0,size(Plots.mean,1)+1],'ylim',max(max(max(abs(Plots.mean(:,nplot2temp,nplot3,:)),[],1),[],2),[],4)*[-1.1,1.1]);
        end
        set(gca,'xtick',1:size(Plots.mean,1),'xticklabel',Plots.title{1}); %,'xcolor','y','ycolor','y');
        hd=title('Effects'); set(hd,'fontsize',18,'fontweight','bold'); %,'color','y');
        hd=ylabel('% Activation change'); set(hd,'fontsize',14,'fontweight','bold'); %,'color','y');
        %%%if ~isempty(Plots.legend), temp={nplot2,nplot3}; temp=temp{Group}; legend(Plots.legend{temp}); end
        view([90,90]); grid on; 
        hd=subplot(132);%set(hd,'units','normalized','position',[.2,.1,.4,.3]);
        % Plots statistics
        Z=Plots.F(:,nplot2,nplot3); Pz=Plots.p(:,nplot2,nplot3); x=1:length(Z);
        i2=bar(x,Z,Pcolors(1)); clim2=max(abs(Z(:)));
        nn=1; for n1=1:length(Plevels),
            idx=find(Pz<Plevels(n1));
            if isempty(idx), break; end
            Z(setdiff(x,idx))=0;
            hold on; hbar=bar(x,Z); set(hbar,'facecolor',Pcolors(1+n1)); hold off;
            nn=nn+1;
        end 
        set(gca,'xtick',1:size(Plots.F,1)); set(gca,'xticklabel',[]); %,'xcolor','y','ycolor','y');
        hd=title('Statistics'); set(hd,'fontsize',18,'fontweight','bold'); %,'color','y');
        hd=ylabel(Plots.xlabel); set(hd,'fontsize',14,'fontweight','bold'); %,'color','y');
        view([90,90]); set(gca,'xlim',[0,size(Plots.F,1)+1],'ylim',max(abs(Plots.F(:,nplot2,nplot3)))*[-1.1,1.1]); grid on;
        
        hd=uicontrol('units','normalized','position',[.64,0,.36,1],'style','frame','backgroundcolor',[.5,0,.5]);
        hd=uicontrol('units','normalized','position',[.65,.65,.35,.35],'style','text','horizontalalignment','left','fontweight','bold','backgroundcolor',[.5,0,.5],'foregroundcolor','y','string',...
            strvcat(...
            Plots.title0, ...
            Plots.title{3}{nplot3}, ...
            [FixedRandom,'-effect analysis'], ...
            Plots.title{2}{nplot2}));
        hd=uicontrol('units','normalized','position',[.65,.2,.35,.6],'style','listbox','horizontalalignment','left','string',...
            strvcat(...
            ['Name : ',Plots.xlabel,' : p'],...
            '_________________',...
            [strvcat(Plots.title{1}{:}),repmat(' : ',[size(Plots.F,1),1]),num2str(Plots.F(:,nplot2,nplot3),'%+8.4f'),repmat(' : ',[size(Plots.F,1),1]),num2str(Plots.p(:,nplot2,nplot3),'%5.4f')],...
            '' ...
            ));

        hd=uicontrol('units','normalized','position',[.7,.05,.25,.1],'style','pushbutton','foregroundcolor','y','backgroundcolor',[.5 .5 0],'fontweight','bold',...
            'string',...
            'Plot spatial effects');
        Contrastplot={idxRegions, Contrast, Level2Contrast};
        if UserOption==1 | UserOption==3, Contrastindex={':',':',nplot3};
        else, Contrastindex={':',nplot2,nplot3}; end
        Contrastindex={Contrastindex{[Group,setdiff(1:3,Group)]}};
        set(hd,'callback',...
            ['spm_ROI_plot_charact([', ...
                num2str(Contrastplot{1}(Contrastindex{1})'),...
                '],[',...
                num2str(Contrastplot{2}(Contrastindex{2})'),...
                '],[',...
                num2str(Contrastplot{3}(Contrastindex{3})'),...
                '],1);']);
    end
end

