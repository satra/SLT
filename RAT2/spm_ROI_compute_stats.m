function [Results,valid]=spm_ROI_compute_stats(UserOption,sidx,Contrast,typelevel2,Level2Contrast,contrast_region);

% spm_ROI_compute_stats Computes 2nd-level (fixed or random effect) statistics
% RESULTS=spm_ROI_compute_stats(opt, sidx,Level1Contrast,typelevel2,Level2Contrast);
% where opt is the type of analysis done
%               1:  region-level test of multiple contrasts
%               2:  region-level test of specific contrast(s)
%               3:  spatial-level test of multiple contrasts
%               4:  spatial-level test of specific contrast(s)
% sidx is a vector of numeric indexes to regions
% Level1Contrast is a vector of numeric indexes to contrasts on the 1st-level effects
% typelevel2 is either 'fixed' or 'random' 
% and Level2Contrast is a vector of numeric indexes to contrasts on the 2nd-level effects
%
% spm_ROI_compute_stats returns a structure array with information on the computed 2nd-level 
% statistics similar to the one output of spm_ROI_glm (only the information in each field is 
% stacked for multiple regions)
%
% see spm_ROI_glm
%

% 04/02
% alfnie@bu.edu

% miscelaneous initializations
FIXEDRANDOM={'fixed','random'};
if ~ischar(typelevel2), typelevel2=FIXEDRANDOM{typelevel2}; end
spm_ROI_input('private.Stage',[mfilename, '{',num2str(UserOption),', ', num2str(sidx(:)'),', ',typelevel2,', ',num2str(Contrast(:)'),', ',num2str(Level2Contrast(:)'),'}']);
%load(spm_ROI_input('files.name_roilabel'),'Label','-mat');
Label = sap_getLabels;
nsubs=length(spm_ROI_input('files.path_subject'));
X=spm_ROI_input('model.DesignMatrix');
C=spm_ROI_input('model.ContrastVector');
X2=spm_ROI_input('model.Level2DesignMatrix');
C2=spm_ROI_input('model.Level2ContrastVector');
ncons=size(C,1);
contrast_multiple_dof=zeros(1,length(X)); 
for n1=1:length(X), % compute multiple contrast dof correction
    X1=orth(X{n1}); Qx=X1'*X{n1}; Qx=pinv(Qx'*Qx)*Qx'; 
    [Csub{1:size(C,1),1}]=deal(C{:,min(n1,size(C,2))});
    c=cell2mat(Csub); c=[c,zeros(size(c,1),size(Qx,1)-size(c,2))]*Qx;
    contrast_multiple_dof(n1)=rank(c(Contrast,:))-rank(c);
end

% Compile stats for multiple subjects
[Stats,valid]=spm_ROI_read_stats(sidx);
sidx=sidx(valid);

% more miscelaneous initializations
nregions=length(sidx);
if nargin<6 | isempty(contrast_region)
    contrast_region=ones(nregions,1);
else
    contrast_region=contrast_region(valid);
end
if strcmp(lower(typelevel2),'fixed'),
    [temp{1:length(Level2Contrast),1}]=deal(C2{Level2Contrast});
    temp=cell2mat(temp);
    contrast_subject=X2*temp';
    idx=find(contrast_subject>0); contrast_subject(idx)=contrast_subject(idx)/sum(contrast_subject(idx));
    idx=find(contrast_subject<0); contrast_subject(idx)=contrast_subject(idx)/sum(-contrast_subject(idx));
    fixedcontrast={contrast_region,contrast_subject};
end
TESTACROSS=[2]; % fixed-effect 2: across-subject statistics, 1: across-regions statistics, random-effect not implemented

% Compute across-subject statistics
switch(lower(typelevel2)),
case 'fixed',
    xsize=size(Stats.con(1).regional.data.h);
    for idx=TESTACROSS, % 1: across-regions, 2: across-subjects
        switch(UserOption),
            
        case 1,                 % region-level test of multiple contrasts
            Results(idx).conAll.regional.data=                       ResultsComputeSum(Stats.conAll.regional.data,idx,fixedcontrast{idx}(:));
            Results(idx).conAll.regional.data.h=                     Results(idx).conAll.regional.data.h(:,:,Contrast,:);
            Results(idx).conAll.regional.data.r=                     Results(idx).conAll.regional.data.r(:,:,Contrast,Contrast);
            Results(idx).conAll.regional.test.dof{1}=                mean(Stats.conAll.regional.test.dof{1},idx);
            Results(idx).conAll.regional.test.dof{2}=                sum(Stats.conAll.regional.test.dof{2},idx);
            Results(idx).conAll.regional.test.dof{3}=                mean(Stats.conAll.regional.test.dof{3},idx)+mean(contrast_multiple_dof,idx);
            h=permute(Results(idx).conAll.regional.data.h,[3,4,1,2]);
            e=permute(Results(idx).conAll.regional.data.E,[3,4,1,2]);
            r=permute(Results(idx).conAll.regional.data.r,[3,4,1,2]);
            dof1=Results(idx).conAll.regional.test.dof{1};
            dof2=Results(idx).conAll.regional.test.dof{2};
            dof3=Results(idx).conAll.regional.test.dof{3};
            xxsize=xsize; xxsize(idx)=1;
            for n1=1:xxsize(1), for n2=1:xxsize(2),
                    Results(idx).conAll.regional.test.F(n1,n2)=      -(dof2(n1,n2)-1/2*(dof1(n1,n2)-dof3(n1,n2)+1))*log(real(det(e(:,:,n1,n2))./det(e(:,:,n1,n2)+h(:,:,n1,n2)'*pinv(r(:,:,n1,n2))*h(:,:,n1,n2))));
                end; end
            Results(idx).conAll.regional.test.p=                     1-spm_Gcdf(Results(idx).conAll.regional.test.F,dof1.*dof3/2,1/2);
            Results(idx).conAll.regional.data.h_conf=                nan*ones(size(Results(idx).conAll.regional.test.p));
            
        case 2,                 % region-level test of specific contrast(s)
            for ncon=Contrast(:)', 
                Results(idx).con(ncon).regional.data=                ResultsComputeSum(Stats.con(ncon).regional.data,idx,fixedcontrast{idx}(:));                                             % Compute across-(subject/region) intermediate variables (effects and error variances)
                Results(idx).con(ncon).regional.test.dof{1}=         mean(Stats.con(ncon).regional.test.dof{1},idx);                                                                    % Compute across-(subject/region) degrees of freedom
                Results(idx).con(ncon).regional.test.dof{2}=         sum(Stats.con(ncon).regional.test.dof{2},idx)+(xsize(idx)-1)*(Results(idx).con(ncon).regional.test.dof{1}-1);
                h=permute(Results(idx).con(ncon).regional.data.h,[3,4,1,2]);
                e=permute(Results(idx).con(ncon).regional.data.E,[3,4,1,2]);
                r=Results(idx).con(ncon).regional.data.r;
                dof1=Results(idx).con(ncon).regional.test.dof{1};
                dof2=Results(idx).con(ncon).regional.test.dof{2};
                xxsize=xsize; xxsize(idx)=1;
                for n1=1:xxsize(1), for n2=1:xxsize(2),
                        Results(idx).con(ncon).regional.test.F(n1,n2)=    real(h(:,:,n1,n2)*pinv(e(:,:,n1,n2))*h(:,:,n1,n2)')/real(r(n1,n2))*dof2(n1,n2)/dof1(n1,n2);                        % Compute across-(subject/region) statistics
                    end; end
                Results(idx).con(ncon).regional.test.p=              1-spm_Fcdf(Results(idx).con(ncon).regional.test.F,dof1,dof2);                                                      % Compute across-(subject/region) p-values
                Results(idx).con(ncon).regional.data.h_conf=         nan*ones(size(Results(idx).con(ncon).regional.test.p));
            end            
            
        case 3,                 % spatial-level test of multiple contrasts
            Results(idx).conAll.spatial.data=                        ResultsComputeSum(Stats.conAll.spatial.data,idx,fixedcontrast{idx}(:));
            Results(idx).conAll.spatial.data.h=                     Results(idx).conAll.spatial.data.h(:,:,Contrast,:);
            Results(idx).conAll.spatial.data.r=                     Results(idx).conAll.spatial.data.r(:,:,Contrast,Contrast);
            Results(idx).conAll.spatial.test.dof{1}=                 mean(Stats.conAll.spatial.test.dof{1},idx)+mean(contrast_multiple_dof,idx);
            Results(idx).conAll.spatial.test.dof{2}=                 sum(Stats.conAll.spatial.test.dof{2},idx)+(xsize(idx)-1)*(Results(idx).conAll.spatial.test.dof{1}-mean(contrast_multiple_dof,idx)-1)+mean(contrast_multiple_dof,idx);
            h=permute(Results(idx).conAll.spatial.data.h,[3,4,1,2]);
            e=Results(idx).conAll.spatial.data.E;
            r=permute(Results(idx).conAll.spatial.data.r,[3,4,1,2]);
            dof1=Results(idx).conAll.spatial.test.dof{1};
            dof2=Results(idx).conAll.spatial.test.dof{2};
            xxsize=xsize; xxsize(idx)=1;
            for n1=1:xxsize(1), for n2=1:xxsize(2),
                    Results(idx).conAll.spatial.test.F(n1,n2)=       real((h(:,:,n1,n2)'*pinv(r(:,:,n1,n2))*h(:,:,n1,n2))/e(n1,n2))*dof2(n1,n2)/dof1(n1,n2);
                end; end
            Results(idx).conAll.spatial.test.p=                      1-spm_Fcdf(Results(idx).conAll.spatial.test.F,dof1,dof2);
            Results(idx).conAll.spatial.data.h_conf=                 nan*ones(size(Results(idx).conAll.spatial.test.p));
            
        case 4,                 % spatial-level test of specific contrast(s)
            for ncon=Contrast(:)', 
                Results(idx).con(ncon).spatial.data=                 ResultsComputeSum(Stats.con(ncon).spatial.data,idx,fixedcontrast{idx}(:)); 
                Results(idx).con(ncon).spatial.test.dof{1}=          sum(Stats.con(ncon).spatial.test.dof{1},idx);
                h=Results(idx).con(ncon).spatial.data.h;
                e=Results(idx).con(ncon).spatial.data.E;
                r=Results(idx).con(ncon).spatial.data.r;
                dof1=Results(idx).con(ncon).spatial.test.dof{1};
                Results(idx).con(ncon).spatial.test.F=               real(h./sqrt(r.*e)).*sqrt(dof1);
                Results(idx).con(ncon).spatial.test.p=               1-spm_Tcdf(abs(Results(idx).con(ncon).spatial.test.F),dof1);
                Results(idx).con(ncon).spatial.data.h_conf=          sqrt(r.*e./dof1).*spm_invTcdf(1-.05,dof1);
            end
            
        end
    end
    
case 'random',
    xsize=size(Stats.con(1).regional.data.h);
    idx=2;
    switch(UserOption),
    case 1,                 % region-level test of multiple contrasts
        q=length(Level2Contrast);
        xxsize=xsize; xxsize(idx)=q;
        for n1=1:xxsize(1), for n2=1:xxsize(2),
                idx0={n1,n2,':',':'}; idx0{idx}=':';
                y=permute(Stats.conAll.regional.data.h(idx0{:}),[idx,3,4,setdiff(1:4,[idx,3,4])]);                                                                           % Subject/region by effect by eigenvariate matrix of effects
                y=y(:,Contrast,:);
                y=y(:,:);
                x=X2;
                b=pinv(x)*y;
                e=y-x*b;
                idx0={n1,n2}; c=C2{Level2Contrast(idx0{idx})};
                h=c*b;
                ee=e'*e;
                r=c*pinv(x'*x)*c';
                dof1=size(y,2);
                dof2=size(y,1)-rank(x)-dof1+1;
                if n1==1 & n2==1, Results(idx).conAll.regional.data.h=zeros([xxsize(1),xxsize(2),length(Contrast),size(b,2)/length(Contrast)]); end
                Results(idx).conAll.regional.data.h(n1,n2,:)=        h;
                Results(idx).conAll.regional.data.e{n1,n2}=          ee;
                Results(idx).conAll.regional.data.r{n1,n2}=          r;
                Results(idx).conAll.regional.test.F(n1,n2)=          real(h*pinv(ee)*h')/real(r)*dof2/dof1;
                if dof2<=0, %warndlg(['Cannot compute regional-level test of all effects using random-effect analysis. minimum subjects = ',num2str(rank(x)+dof1)],'spm_ROI: Warning!...','replace'); 
                    Results(idx).conAll.regional.test.p(n1,n2)=          nan;
                else
                    Results(idx).conAll.regional.test.p(n1,n2)=          1-spm_Fcdf(Results(idx).conAll.regional.test.F(n1,n2),dof1,dof2);
                end
                Results(idx).conAll.regional.test.dof{1}(n1,n2)=     dof1;
                Results(idx).conAll.regional.test.dof{2}(n1,n2)=     dof2;
                Results(idx).conAll.regional.data.h_conf(n1,n2)=     nan;
            end; end
        
    case 2,                 % region-level test of specific contrast(s)
        q=length(Level2Contrast);
        xxsize=xsize; xxsize(idx)=q;
        for ncon=Contrast(:)', 
            for n1=1:xxsize(1), for n2=1:xxsize(2),
                    idx0={n1,n2,':',':'}; idx0{idx}=':';
                    y=permute(Stats.con(ncon).regional.data.h(idx0{:}),[idx,4,setdiff(1:4,[idx,4])]);                                                                                                  % Subject/region by eigenvariate matrix of effects
                    x=X2;
                    b=pinv(x)*y;
                    e=y-x*b;
                    idx0={n1,n2}; c=C2{Level2Contrast(idx0{idx})};
                    h=c*b;
                    ee=e'*e;
                    r=c*pinv(x'*x)*c';
                    dof1=size(y,2);
                    dof2=size(y,1)-rank(x)-dof1+1;
                    if n1==1 & n2==1, Results(idx).con(ncon).regional.data.h=zeros([xxsize(1),xxsize(2),1,size(b,2)]); end
                    Results(idx).con(ncon).regional.data.h(n1,n2,:)=    h;
                    Results(idx).con(ncon).regional.data.e{n1,n2}=      ee;
                    Results(idx).con(ncon).regional.data.r{n1,n2}=      r;
                    Results(idx).con(ncon).regional.test.F(n1,n2)=      real(h*pinv(ee)*h')/real(r)*dof2/dof1;
                    if dof2<=0, %warndlg(['Cannot compute region-level test of specific contrast using random-effect analysis. minimum subjects = ',num2str(rank(x)+dof1)],'spm_ROI: Warning!.','replace'); 
                        Results(idx).con(ncon).regional.test.p(n1,n2)=      nan;
                    else
                        Results(idx).con(ncon).regional.test.p(n1,n2)=      1-spm_Fcdf(Results(idx).con(ncon).regional.test.F(n1,n2),dof1,dof2);
                    end
                    Results(idx).con(ncon).regional.test.dof{1}(n1,n2)=    dof1;
                    Results(idx).con(ncon).regional.test.dof{2}(n1,n2)=    dof2;
                    Results(idx).con(ncon).regional.data.h_conf(n1,n2)= nan;
                end; end
        end
        
    case 3,                 % spatial-level test of multiple contrasts
        q=length(Level2Contrast);
        xxsize=xsize; xxsize(idx)=q;
        for n1=1:xxsize(1), for n2=1:xxsize(2),
                idx0={n1,n2,':',':'}; idx0{idx}=':';
                y=permute(Stats.conAll.spatial.data.h(idx0{:}),[idx,3,setdiff(1:4,[idx,3])]);                                                                                                  % Subject/region by contrast matrix of effects
                y=y(:,Contrast);
                x=X2;
                b=pinv(x)*y;
                e=y-x*b;
                idx0={n1,n2}; c=C2{Level2Contrast(idx0{idx})};
                h=c*b;
                ee=e'*e;
                r=c*pinv(x'*x)*c';
                dof1=size(y,2);
                dof2=size(y,1)-rank(x)-dof1+1;
                if n1==1 & n2==1, Results(idx).conAll.spatial.data.h=zeros([xxsize(1),xxsize(2),length(Contrast),size(b,2)/length(Contrast)]); end
                Results(idx).conAll.spatial.data.h(n1,n2,:)=        h;
                Results(idx).conAll.spatial.data.e{n1,n2}=          ee;
                Results(idx).conAll.spatial.data.r{n1,n2}=          r;
                Results(idx).conAll.spatial.test.F(n1,n2)=          real(h*pinv(ee)*h')/real(r)*dof2/dof1;
                if dof2<=0, %warndlg(['Cannot compute spatial-level test of all effects using random-effect analysis. minimum subjects = ',num2str(rank(x)+dof1)],'spm_ROI: Warning!..','replace'); 
                    Results(idx).conAll.spatial.test.p(n1,n2)=          nan;
                else
                    Results(idx).conAll.spatial.test.p(n1,n2)=          1-spm_Fcdf(Results(idx).conAll.spatial.test.F(n1,n2),dof1,dof2);
                end
                Results(idx).conAll.spatial.test.dof{1}(n1,n2)=     dof1;
                Results(idx).conAll.spatial.test.dof{2}(n1,n2)=     dof2;
                Results(idx).conAll.spatial.data.h_conf(n1,n2)=     nan;
            end; end
        
    case 4,                 % spatial-level test of specific contrast(s)
        q=length(Level2Contrast);
        xxsize=xsize; xxsize(idx)=q;
        for ncon=Contrast(:)', 
            for n1=1:xxsize(1), for n2=1:xxsize(2),
                    idx0={n1,n2,':',':'}; idx0{idx}=':';
                    y=permute(Stats.con(ncon).spatial.data.h(idx0{:}),[idx,4,setdiff(1:4,[idx,4])]);                                                                                                % Subject/region by 1 matrix of effects
                    x=X2;
                    b=pinv(x)*y;
                    e=y-x*b;
                    idx0={n1,n2}; c=C2{Level2Contrast(idx0{idx})};
                    h=c*b;
                    ee=e'*e;
                    r=c*pinv(x'*x)*c';
                    dof=size(y,1)-1;
                    Results(idx).con(ncon).spatial.data.h(n1,n2)=      h;
                    Results(idx).con(ncon).spatial.data.e(n1,n2)=      ee;
                    Results(idx).con(ncon).spatial.data.r(n1,n2)=      r;
                    Results(idx).con(ncon).spatial.test.F(n1,n2)=      real(h/sqrt(r*ee))*sqrt(dof);
                    Results(idx).con(ncon).spatial.test.p(n1,n2)=      1-spm_Tcdf(abs(Results(idx).con(ncon).spatial.test.F(n1,n2)),dof);
                    Results(idx).con(ncon).spatial.test.dof(n1,n2)=    dof;
                    Results(idx).con(ncon).spatial.data.h_conf(n1,n2)= sqrt(r.*ee./dof).*spm_invTcdf(1-.05,dof);
                end; end
        end
        
    end
end
if length(TESTACROSS)==1, Results=Results(TESTACROSS); end

function Resultscon=ResultsComputeSum(Statscon,idx,contrast);
contrast=shiftdim(contrast(:),1-idx);

s=size(Statscon.h); s(idx)=1; contrast0=repmat(contrast,s);
Resultscon.h=sum(Statscon.h.*contrast0,idx);
Resultscon.E=sum(Statscon.E,idx);
s=size(Statscon.r); s(idx)=1; contrast0=repmat(contrast,s);
Resultscon.r=sum(Statscon.r.*contrast0.^2,idx);
