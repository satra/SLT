function name=spm_ROI_combine(exptfilename,combinationsfile);

% SPM_ROI_COMBINE performs ROI combinations
%
% spm_ROI_combine(exptfilename,combinationsfile) reads
% the text file combinationsfile for keys to define
% new ROI's by combining existing ones. This file must
% contain lines with format:
%    nameNEWregion = nameOLDregion1 + nameOLDregion2 + ...
% Lines which cannot be interpreted are ignored.
% spm_ROI_combine creates a set of new ROI mask files, and
% modifies the experiment structure to point to it.
%

% 01/04
% alfnie@bu.edu

if ~ischar(exptfilename), exptfilename=exptfilename.filename; end
%[pth,nm]=fileparts(exptfilename); exptfilename=fullfile(pth,[nm,'.mat']);
load(exptfilename,'expt','-mat');
Label = sap_getLabels;
Nmask=length(Label);
idxRegion=strmatch('',Label,'exact'); idxRegion=setdiff(1:Nmask,idxRegion); % note: skip regions with an empty string label

% reads rules from file
data=textread(combinationsfile,'%s','delimiter','\n');
nrule=0; clear Rule;
for n1=1:length(data),
    tempFrom=[];
    [a,b]=strtok(data{n1},'=');
    if ~isempty(a), 
        tempTo=strmatch(fliplr(deblank(fliplr(deblank(a)))),Label,'exact');
        fprintf([deblank(a),' (',num2str(tempTo),') = ']);
    end
    while ~isempty(a) & ~isempty(b),
        [a,b]=strtok(b(2:end),'+');
        tempFrom1=strmatch(fliplr(deblank(fliplr(deblank(a)))),Label,'exact');
        fprintf([deblank(a),' (',num2str(tempFrom1),')  ']);
        tempFrom=[tempFrom,tempFrom1];
    end
    if ~isempty(tempFrom) & ~isempty(tempTo),
        nrule=nrule+1;
        Rule(nrule)=struct(...
            'To',tempTo,...
            'From',tempFrom);
        disp('   : Rule accepted');
    else,
        fprintf('\n');
    end
end
if ~nrule, return; end

% finds mask files
Nsubs=length(expt.subject);
for nsub=1:Nsubs,
    oldmask{nsub}=expt.subject(nsub).roidata(1).mask;
end

% creates new mask files
for nsub=1:Nsubs,
    maskfile1=spm_vol(oldmask{nsub});
    mask1=spm_read_vols(maskfile1);
    mask2=zeros(size(mask1));
    for nrule=1:length(Rule),
        for nsource=1:length(Rule(nrule).From),
            idx=find(round(mask1)==Rule(nrule).From(nsource));
            mask2(idx)=Rule(nrule).To;
        end
    end
    maskfile2=maskfile1;
    maskfile2.fname=[maskfile2.fname,'COMB.img'];
    spm_write_vol(maskfile2,mask2);
end

% modify experiment structure
for nsub=1:Nsubs,
    Nsess=length(expt.subject(nsub).roidata);
    for nsess=1:Nsess,
        expt.subject(nsub).roidata(nsess).mask=[oldmask{nsub},'COMB.img'];
    end
end
expt.desc=[expt.desc,' COMBINED ROIs'];
save([exptfilename,'COMB.expt'],'expt');



    