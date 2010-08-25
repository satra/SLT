% spm_ROI_read_stats
% Compiles stat info from multiple regions/subjects/contrasts
% This function is for internal use of spm_ROI_compute_stats
% [Results,valid]=spm_ROI_read_stats(idxRegion)
% where idxRegion is a vector of numeric indexes to ROIs 
% returns a structure with all the subject statistics 
% combining the individual statistics as output of spm_ROI_glm.
% valid is a logic vector specifying whether it was possible to
% retrieve this information for each region.
%

% 02/02
% alfnie@bu.edu

function [Results,valid]=spm_ROI_read_stats(sidx);
%%%global talytal

path_subject=spm_ROI_input('files.path_subject');
%load(spm_ROI_input('files.name_roilabel'),'Label','-mat');
Label = sap_getLabels;
nsubs=length(path_subject); 
if ischar(sidx),
  nregion=[]; 
  for n1=1:size(sidx,1), nregion=[nregion,strmatch(deblank(sidx(n1, ...
                                                      :)),Label,'exact')]; ...
         end;
  sidx=nregion;
end  
nregions=length(sidx);
valid=ones(size(sidx));

hwaitbar=waitbar(0,'spm_{ROI}: Reading subject stats...');
FIRST=1; for nregion=1:nregions,
    % Get stats for each region for each subject
    for nsub=1:nsubs,
        waitbar(((nregion-1)*nsubs+nsub)/nsubs/nregions,hwaitbar);    set(hwaitbar,'name', ['Region ',Label{sidx(nregion)},' - Subject ', num2str(nsub)]);
        cwd=path_subject{nsub};
        filename=[cwd,filesep,'ROIdata_',num2str(sidx(nregion)*(~strcmp(Label{sidx(nregion)},'Global')),'%05d'),'.stat.mat'];
        %%%filename=[cwd,filesep,'ROIdata_',num2str(sidx(nregion)*(~strcmp(Label{sidx(nregion)},'Global')),'%05d'),talytal,'.stat.mat'];
        dirnames=dir(filename);
        if ~isempty(dirnames), 
            data=load(filename,'-mat');
            if ~isempty(data.Stat),
                if FIRST, FIRST=0;
                    % Initialize
                    ncons=length(data.Stat.con);
                    for ncon=1:ncons, Results.con(ncon).regional=ResultsInit([nregions,nsubs],data.Stat.con(ncon).regional); end
                    for ncon=1:ncons, Results.con(ncon).spatial=ResultsInit([nregions,nsubs],data.Stat.con(ncon).spatial); end
                    Results.conAll.regional=ResultsInit([nregions,nsubs],data.Stat.conAll.regional);
                    Results.conAll.spatial=ResultsInit([nregions,nsubs],data.Stat.conAll.spatial);
                end
                % read
                for ncon=1:ncons, Results.con(ncon).regional=ResultsRead([nregion,nsub],Results.con(ncon).regional,data.Stat.con(ncon).regional); end
                for ncon=1:ncons, Results.con(ncon).spatial=ResultsRead([nregion,nsub],Results.con(ncon).spatial,data.Stat.con(ncon).spatial); end
                Results.conAll.regional=ResultsRead([nregion,nsub],Results.conAll.regional,data.Stat.conAll.regional); 
                Results.conAll.spatial=ResultsRead([nregion,nsub],Results.conAll.spatial,data.Stat.conAll.spatial); 
            else valid(nregion)=0; end
        else valid(nregion)=0; disp([filename, ' not found']); end
    end
end;

close(hwaitbar);
valid=logical(valid);
if any(~valid), 
    for ncon=1:ncons,
        Results.con(ncon).regional=ResultsDeleterows(~valid, Results.con(ncon).regional);
        Results.con(ncon).spatial=ResultsDeleterows(~valid, Results.con(ncon).spatial);
    end
    Results.conAll.regional=ResultsDeleterows(~valid, Results.conAll.regional);
    Results.conAll.spatial=ResultsDeleterows(~valid, Results.conAll.spatial);
    disp('spm_ROI: warning, some regions did have missing stats and were removed from the analyses'); 
end

function Resultscon=ResultsInit(xsize,Statcon);
Resultscon.test.F=nan*ones(xsize); 
Resultscon.test.p=nan*ones(xsize);
[Resultscon.test.dof{1:length(Statcon.test.dof)}]=deal(nan*ones([xsize]));
Resultscon.data.E=zeros([xsize,size(Statcon.data.E)]);
Resultscon.data.h=nan*ones([xsize,size(Statcon.data.h)]);
Resultscon.data.r=zeros([xsize,size(Statcon.data.r)]);

function Resultscon=ResultsRead(xsize,Resultscon,Statcon);
Resultscon.test.F(xsize(1),xsize(2),:)=Statcon.test.F(:);
Resultscon.test.p(xsize(1),xsize(2),:)=Statcon.test.p(:);
for ndof=1:length(Resultscon.test.dof), Resultscon.test.dof{ndof}(xsize(1),xsize(2),:)=Statcon.test.dof(ndof); end
Resultscon.data.E(xsize(1),xsize(2),:)=Statcon.data.E(:);
Resultscon.data.h(xsize(1),xsize(2),:)=Statcon.data.h(:);
Resultscon.data.r(xsize(1),xsize(2),:)=Statcon.data.r(:);

function Resultscon=ResultsDeleterows(idx,Resultscon);
Resultscon.test.F(idx,:,:,:,:)=[];
Resultscon.test.p(idx,:,:,:,:)=[];
for ndof=1:length(Resultscon.test.dof), Resultscon.test.dof{ndof}(idx,:,:,:,:)=[]; end
Resultscon.data.E(idx,:,:,:,:)=[];
Resultscon.data.h(idx,:,:,:,:)=[];
Resultscon.data.r(idx,:,:,:,:)=[];
