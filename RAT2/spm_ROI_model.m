% SPM_ROI_MODEL ROI model estimation & hypothesis testing
%
% spm_ROI_model(idxregions) performs ROI analyses on the
% selected regions (idxregions can be a numeric array of indexes 
% to regions or a character array of region names)
% spm_ROI_model without arguments performs ROI analyses on all 
% available regions
%

% 07/01
% alfnie@bu.edu

function spm_ROI_model(idxregions);

if nargin<1, idxregions=[]; end
spm_ROI_input('private.Stage',mfilename);
load(spm_ROI_input('files.name_experiment'),'expt','-mat');
X=spm_ROI_input('model.DesignMatrix');
C=spm_ROI_input('model.ContrastVector');
Cfx=spm_ROI_input('model.ContrastSpatialVector');
Label=sap_getLabels;
path_subject=spm_ROI_input('files.path_subject');

if ischar(idxregions), 
    nregion=[]; 
    for n1=1:size(idxregions,1), nregion=[nregion, strmatch(deblank(idxregions(n1,:)),Label,'exact')]; end; 
    if length(nregion)~=size(idxregions,1), disp(strvcat(Label{nregion})); error('region name mismatch'); return; end
    idxregions=nregion;
end


nsubs=length(expt.subject);
idxsubs=1:nsubs;
PWD=pwd;
for nsub=idxsubs,
   cwd=path_subject{nsub}; 
   % Get filenames for subject
   spm_ROI_input('private.Stage',['Model stage: ',path_subject{nsub}]);
   validsess = []; validfiles=[];
   for n1=1:length(expt.subject(nsub).roidata), 
       % Jay B - 05/10/05 changed 'all' to 'any'
       if any(expt.subject(nsub).roidata(n1).validfiles),
	   validsess = union(validsess,n1);
           validfiles = [validfiles;expt.subject(nsub).roidata(n1).validfiles];
       end
   end;

   if isempty(idxregions), 
       for n1=validsess(:)',  
           idxregions=[idxregions; ...
                   expt.subject(nsub).roidata(n1).PUlist];
       end; 
       idxregions=unique(idxregions);
   end

   nregions=length(idxregions); 
   idxglobal=find(idxregions==0);
   [Csub{1:size(C,1),1}]=deal(C{:,min(size(C,2),nsub)});
   
   % All the analyses for each region
   disp(['spm_ROI: analyzing data for subject ',num2str(nsub),'/',num2str(nsubs),' ROIs defined: ',num2str(nregions),'(',datestr(now),') ']);
   clear R Stats xyz

   for nregion=1:nregions,
      filename=sprintf('ROIdata_%05d',idxregions(nregion));
      R{1}=[]; G{1}=[];
      
      for nsess=validsess(:)', 
          idxregion=find(expt.subject(nsub).roidata(nsess).PUlist==idxregions(nregion));
          if isempty(idxregion),break; end
          if isempty(dir(deblank(expt.subject(nsub).roidata(nsess).data(idxregion,:)))),
              spm_ROI_input('private.Stage',['No data for region in ',deblank(expt.subject(nsub).roidata(nsess).data(idxregion,:))]);
              R{1}=[];
              data.xY.XYZmm=zeros(3,0);
          else,
              data=load(deblank(expt.subject(nsub).roidata(nsess).data(idxregion,:)),'-mat');
	      R{1}=[R{1};detrend(data.xY.y*(mean(data.xY.gx))./repmat(data.xY.gx,[1,size(data.xY.y,2)]))]; 
              if spm_ROI_input('model.RemoveGlobal'), 
		  G{1} = [G{1};detrend(data.xY.gx)];
	      else,
		%  R{1}=[R{1};detrend(data.xY.y)];
	      end
          end
      end
      if ~isempty(idxregion) & ~isempty(R{1}) & (size(R{1},2)<7000) & (size(R{1},2)>10), %size threshold
          % cartesian2spherical transform
	  thphidx=find(~any(isnan(data.xY.XYZmm),1));
          if expt.design.useSPHcoords & ~isempty(thphidx), %~isempty(data.xY.XYZmm),
              spm_ROI_input('private.Stage',['Spherical projection']);   
              a=repmat(mean(data.xY.XYZmm(:,thphidx),2),[1,length(thphidx)]); b=data.xY.XYZmm(:,thphidx)-a; c=b*b'/length(thphidx); d=sum(b.*(pinv(c)*b)); thphidx(d>100)=[]; if any(d>100), disp(['remove ',num2str(sum(d>100)),' from ',filename]); end
              [th,ph,rr]=cart2sph(data.xY.XYZmm(1,thphidx),data.xY.XYZmm(2,thphidx),data.xY.XYZmm(3,thphidx));
              th0=angle(sum(exp(j*th))); th=th0+angle(exp(j*(th-th0)));
              ph0=angle(sum(exp(j*ph))); ph=ph0+angle(exp(j*(ph-ph0)));
              xyz{1}=[th;ph];
              R{1}=R{1}(:,thphidx);
              XYZCart=data.xY.XYZCart(:,thphidx);
          else,
              spm_ROI_input('private.Stage',['Cartesian projection']);
              xyz{1}=data.xY.XYZCart;
              XYZCart=data.xY.XYZCart;
          end
          if spm_ROI_input('private.FromFilePreprocessing') & ~isempty(dir([cwd,filesep,filename,'.roi.mat'])),
              spm_ROI_input('private.Stage',['From-File-Preprocessing ',cwd,filesep,filename,'.roi.mat']);
              data = load([cwd,filesep,filename,'.roi.mat']);
              R{1}=data.Z;
          end
          % remove invalid scans
          for n1=1:length(R), R{n1}(~validfiles,:)=[]; end;
          if ~isempty(G{1}), 
            for n1=1:length(G), G{n1}(~validfiles,:)=[]; end;
            X{min(length(X),nsub)}=[X{min(length(X),nsub)},G{1}]; 
          end
          
          % Analyze data
          if ~isempty(dir(deblank([cwd,filesep,filename,'.stat.mat']))), ...
                load(deblank([cwd,filesep,filename,'.stat.mat']),'Stat','XYZ','XYZCart'); Stats{1}=Stat; Zs{1}=[]; else, Stats{1}=[]; Zs{1}=[]; end
          if size(X{min(length(X),nsub)},1)~=size(R{1},1), ...
                error(['Non-matching sizes of design matrix ' ...
                       '(',num2str(size(X{min(length(X),nsub)},1)),[') ' ...
                                'and data ('], num2str(size(R{1},1)),')']); ...
                
                end
          [Stats,Zs]=spm_ROI_glm(X{min(length(X),nsub)},Csub,R,xyz,Cfx,{Label{idxregions(nregion)}});
   
          % save results for each region
          if ~isempty(Stats{1}),
              spm_ROI_input('private.Stage',['Saving ',cwd,filesep,filename,'.stat.mat']);
              Stat = Stats{1}; XYZ = xyz{1};
              save([cwd,filesep,filename,'.stat.mat'],'Stat','XYZ','XYZCart');
          end
          if ~isempty(Zs{1}),
              spm_ROI_input('private.Stage',['Saving ',cwd,filesep,filename,'.roi.mat']);
              Z=Zs{1};
              save([cwd,filesep,filename,'.roi.mat'],'Z');
          end
      end
   end
end

spm_ROI_input('private.FromFilePreprocessing',0);
spm_ROI_input('private.Stage',['Ending ',mfilename]);

