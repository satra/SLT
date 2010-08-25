function [Stats,Z]=spm_ROI_glm(X,C,Y,XYZ,Cfx,Label);
% spm_ROI_glm General Linear Model and hypothesis testing
% Stats=spm_ROI_glm(X,C,Y,xyz,Cfx,Label);
% Fits the model
%       Y{i} = X * B{i} + noise
% and tests the hypotheses
%       C{j}'*B{i} = 0                  REGIONAL-level hypothesis
%       C{j}'*B{i}*Cfx(xyz{i}) = 0      SPATIAL-level hyothesis
%
% where 
%		Y{i}	: is a [Nt,Np] matrix of Np (voxels) timecourses
%		X		: is the [Nt,Na] design matrix
%		C{j}	: is a [Na,1] contrast vector
%       xyz{i}  : is a [3,Np] matrix of 3-d voxel coordinates (in mm)
%		Cfx	    : is a string containing a functional form of the spatial contrast vector
%
% noise is fitted using a mixture model reduced to a pre-defined frequency of interest window.
% Other parameteres required (TR, data reduction type and level, and frequency of interest window) are read from the project database using spm_ROI_input
%
% spm_ROI_glm returns a cell array Stats with a structure Stats{i} for each region tested with fields
% .con(i).regional           contains region-level statistics on test of specific contrasts (F statistics)
% .con(i).spatial            contains spatial-level statistics on test of specific contrasts (T statistics)
% .conAll.regional           contains region-level statistics on test of all effects (Bartlett's chi-square approximation to lambda statistics)
% .conAll.spatial            contains spatial-level statistics on test of all effects (F statistics)
% Each of this is a strucure containing the fields
%       .data.h                     effects
%       .data.E                     error variances
%       .data.r                     scaling factor for error variances 
%       .test.F                     test statistics
%       .test.p                     test significance level
%       .test.dof                   degrees of freedom
%

%

% alfnie@bu.edu
% 1/01
%

spm_ROI_input('private.Stage',[mfilename]);
RT=spm_ROI_input('model.RepetitionTime');
NS=spm_ROI_input('model.DataReductionLevel');
WT=spm_ROI_input('model.Whitening');
ROI_base=spm_ROI_input('model.DataReductionType');
minPrd=spm_ROI_input('model.MinPeriod');
maxPrd=spm_ROI_input('model.MaxPeriod');

minPrd=max(minPrd,1);%%%%%%%%%%%%%%%%%%
[Nt0,Na]=size(X);
Nc=length(C);
Nr=length(Y);
Cffx=inline([Cfx,'+0*x'],'x','y','z'); 

minF=max(1,min(floor(Nt0/2),floor(Nt0/maxPrd*RT)));
maxF=max(1,min(floor(Nt0/2),ceil(Nt0/minPrd*RT)));
idxF=[minF:maxF, Nt0+2-(max(2,minF):maxF)];

% Correction for design matrix of degenerate rank
X1=orth(X);
Nx=size(X1,2);	%rank(X)
Qx=X1'*X; Qx=pinv(Qx'*Qx)*Qx';
Nf=length(idxF);
dof=Nf-Nx;
X2a=fft(X1,Nt0); 

%%disp(['Nt : ',num2str(Nt0),'    dof : ',num2str(dof)]);
%%hwaitbar=waitbar(0,'spm_{ROI}: Subject model estimation');
for nr=1:Nr,
    if isempty(Y{nr}), % | isempty(XYZ{nr}),
        spm_ROI_input('private.Stage','Empty data');
        Stats{nr}=[];
        Z{nr}=[];
    else, 
        spm_ROI_input('private.Stage',[mfilename, '{',Label{nr}, ', data: ',num2str(size(Y{nr})),', design: ',num2str(size(X2a)),', contrast: ',Cfx,'}']);
        if isstruct(Y{nr}),
            Y1=Y{nr}.PrivateY1;
            Y2=Y{nr}.PrivateY2;
            X2=Y{nr}.PrivateX2;
            fe=Y{nr}.WhiteningVector;
            if isempty(XYZ{nr}), Qr=Y{nr}.ReductionMatrix;
            else, Qr=spm_ROI_glm_datared(ROI_base,XYZ{nr},Cffx,Y1,NS); end
            Y2=Y1*Qr;
            spm_ROI_input('private.Stage',['Data reduction ',ROI_base,' (',num2str(NS),') : ',num2str(100*sum(abs(Y2(:)).^2)./sum(abs(Y1(:)).^2)),'%']);
            Ns=size(Y2,2);
            iX2=pinv(X2'*X2);
            Z{nr}=[];
            disp(['Region ',Label{nr}]);
            
        else, % Preprocessing
            [Nt,Np]=size(Y{nr});
            Ns=min(Np,NS);    		% number of spatial components retained for each region
            Y0=fft(Y{nr},Nt0);
            
            % Correction for temporally correlated noise
            if WT,
                E1=Y0 - X2a*(pinv(X2a'*X2a)*(X2a'*Y0)); % Initial noise estimation
%global tal1 tal2
%tal1=X2a;
%tal2=Y0;
%disp(any(any(isnan(Y0))))
%disp(any(any(isnan(X2a))))
%disp(any(any(isinf(pinv(X2a'*X2a)))));
%disp(any(any(isinf(X2a'*Y0))));
%pinv(real(X2a'*X2a))
%disp(any(any(isnan((pinv(X2a'*X2a)*(X2a'*Y0))))));
%disp(any(any(isnan(E1))));
                mY=mean(abs(E1).^2,2);
%disp(any(isnan(mY)))
                [params,fe,nill,mY_corr]=spm_ROI_FitErr_em(mY,X2a, ...
							   minF,maxF);
                Y1=Y0(idxF,:)./(eps+sqrt(fe(idxF,ones(1,Np))));
                X2=X2a(idxF,:)./(eps+sqrt(fe(idxF,ones(1,Nx))));
                disp(['Region ',Label{nr},' (',num2str(Np),'voxels ',' serialcorr=',num2str(RT*Nt0/(2*pi)/params(3)/sqrt(2)*sqrt(8*log(2)),'%5.1f'),'s peakratio=',num2str(params(1)/params(2),'%5.1f'),':1)']);
                spm_ROI_input('private.Stage',['Region ',Label{nr},' (',num2str(Np),'voxels ',' serialcorr=',num2str(RT*Nt0/(2*pi)/params(3)/sqrt(2)*sqrt(8*log(2)),'%5.1f'),'s peakratio=',num2str(params(1)/params(2),'%5.1f'),':1)']);
            else,
                Y1=Y0(idxF,:);
                X2=X2a(idxF,:);
                disp(['Region ',Label{nr},' (',num2str(Np),'voxels) ']);
                spm_ROI_input('private.Stage',['Region ',Label{nr},' (',num2str(Np),'voxels) ']);
            end
            iX2=pinv(X2'*X2);  
            
            
            Qr=spm_ROI_glm_datared(ROI_base,XYZ{nr},Cffx,Y1,NS);
            Y2=Y1*Qr;
            spm_ROI_input('private.Stage',['Data reduction ',ROI_base,' (',num2str(Ns),') : ',num2str(100*sum(abs(Y2(:)).^2)./sum(abs(Y1(:)).^2)),'%']);
            
            % Time-series to test
            if WT,
                DataRess=zeros(Nt0,1); DataRess(idxF)=sqrt(mY_corr(idxF,:))./(eps+sqrt(fe(idxF))); DataRess=ifft(DataRess,Nt0);
                DataRegion=zeros(Nt0,NS); DataRegion(idxF,:)=Y2.*sqrt(fe(idxF,ones(1,NS))); DataRegion=ifft(DataRegion,Nt0);
                Z{nr}=struct(...
                    'DataRess',DataRess,...
                    'DataRegion',DataRegion,...
                    'ReductionMatrix',Qr,...
                    'WhiteningVector',fe,...
                    'PrivateY1',Y1,...
                    'PrivateY2',Y2,...
                    'PrivateX2',X2 ...
                );
            else, Z{nr}=[]; end
        end
        
        % Least square estimation
        B=iX2*(X2'*Y2);
        
        % General Linear Hypothesis. (LRT) Likelihood Ratio Test
        E=Y2-X2*B;
        EE=E'*E;
        iE=pinv(EE);

        % General Linear Hypothesis. Spatial-contrast computations
        m=strfind(lower(Cfx),'base');
        if ~isempty(m),
            m=max(1,min(Ns,str2num(['0',Cfx(m+4:end)])));
            Y2m=Y2(:,m);
        else
            if size(XYZ{nr},1)>2, m=Cffx(XYZ{nr}(1,:)',XYZ{nr}(2,:)',XYZ{nr}(3,:)'); 
            else, m=Cffx(XYZ{nr}(1,:)',XYZ{nr}(2,:)',zeros(size(XYZ{nr},2),1)); end
            if isempty(m), m=ones(Np,1); end							% contrast along spatial dimensions for T statistics
            m=m/(eps+sum(abs(m)));
            Y2m=Y1*m;
        end
        Bm=iX2*(X2'*Y2m);
        Em=Y2m-X2*Bm;
        EEm=Em'*Em;
        
        %DataRess=zeros(Nt0,1); DataRess=mean(Y0,2); DataRess=real(ifft(DataRess,Nt0));
        %plot(DataRess,'c'); set(gca,'xtick',0:15:Nt0); grid on; hold on;
        %DataRess=zeros(Nt0,1); DataRess(idxF)=Em.*(eps+sqrt(fe(idxF))); DataRess=real(ifft(DataRess,Nt0));
        %plot(DataRess,'r'); set(gca,'xtick',0:15:Nt0); grid on; hold on;
        %DataRess=zeros(Nt0,1); DataRess(idxF)=Y2m.*(eps+sqrt(fe(idxF))); DataRess=real(ifft(DataRess,Nt0));
        %plot(DataRess,'k','linewidth',2); set(gca,'xtick',0:15:Nt0); grid on; hold on;
        %DataRess=zeros(Nt0,1); DataRess(idxF)=(X2*Bm).*(eps+sqrt(fe(idxF))); DataRess=real(ifft(DataRess,Nt0));
        %plot(DataRess,'b','linewidth',2); set(gca,'xtick',0:15:Nt0); grid on; hold off;
        %pause;

        for nc=1:Nc,		% test each contrast
            c=[C{nc}(:);zeros(size(Qx,1)-length(C{nc}),1)]'*Qx;
            h=c*B;
            r=c*iX2*c';

            % Spatial-contrast computations
            hm=c*Bm;
            rm=c*iX2*c';
            
            % Output statistics
            Stats{nr}.con(nc).profiles.spatial=		    h*Qr';
            
            % F-test on regional effect
            Stats{nr}.con(nc).regional.data.h=			h;
            Stats{nr}.con(nc).regional.data.E=			EE;
            Stats{nr}.con(nc).regional.data.r=			r;
            Stats{nr}.con(nc).regional.test.F=			real((h*iE*h')/r)*(dof-Ns+1)/Ns;
            Stats{nr}.con(nc).regional.test.p=			1-spm_Fcdf(Stats{nr}.con(nc).regional.test.F,Ns,dof-Ns+1);
            Stats{nr}.con(nc).regional.test.dof=		[Ns, dof-Ns+1];
            
            % T-test on spatial-contrast effect
            Stats{nr}.con(nc).spatial.data.h=			hm;
            Stats{nr}.con(nc).spatial.data.E=			EEm;
            Stats{nr}.con(nc).spatial.data.r=			rm;
            Stats{nr}.con(nc).spatial.test.F=			real(hm/sqrt(rm*EEm))*sqrt(dof);
            Stats{nr}.con(nc).spatial.test.p=			1-spm_Tcdf(Stats{nr}.con(nc).spatial.test.F,dof);
            Stats{nr}.con(nc).spatial.test.dof=			[dof];
        end
        
        c=[cell2mat(C),zeros(length(C),size(Qx,1)-length(C{1}))]*Qx;
        Nc0=rank(c);

        % simultaneous test on all effects for regional effect
        h=c*B;
        r=c*iX2*c';
        Stats{nr}.conAll.profiles.spatial=		        h*Qr';
        Stats{nr}.conAll.regional.data.h=               h;
        Stats{nr}.conAll.regional.data.E=			    EE;
        Stats{nr}.conAll.regional.data.r=			    r;
        Stats{nr}.conAll.regional.test.F=               -(dof-1/2*(Ns-Nc0+1))*log(real(det(EE)./det(EE+h'*pinv(r)*h)));
        Stats{nr}.conAll.regional.test.p=               1-spm_Gcdf(Stats{nr}.conAll.regional.test.F,Ns*Nc0/2,1/2);
        Stats{nr}.conAll.regional.test.dof=             [Ns,dof,Nc0];

        % simultaneous test on all effects for spatial-contrast effect
        hm=c*Bm;
        rm=c*iX2*c';
        Stats{nr}.conAll.spatial.data.h=                hm;
        Stats{nr}.conAll.spatial.data.E=			    EEm;
        Stats{nr}.conAll.spatial.data.r=			    rm;
        Stats{nr}.conAll.spatial.test.F=                real((hm'*pinv(rm)*hm)/EEm)*(dof-Nc0+1)/Nc0;
        Stats{nr}.conAll.spatial.test.p=                1-spm_Fcdf(Stats{nr}.conAll.spatial.test.F,Nc0,dof-Nc0+1);
        Stats{nr}.conAll.spatial.test.dof=              [Nc0, dof-Nc0+1];
    end
%%    waitbar(nr/Nr,hwaitbar);
end
%%close(hwaitbar);

function Qr=spm_ROI_glm_datared(ROI_base,XYZ,Cffx,Y1,Ns);
% Data reduction
switch(ROI_base),
case 'SVD',
    %[Ql,Dr,Qr]=svd(Y1,0);
    [Ql,Dr,Qr]=svds(Y1,Ns);
    Qr=Qr(:,1:Ns)*diag(sign(real(sum(Qr(:,1:Ns),1))));
    Qr=cat(2,Qr,zeros(size(Qr,1),Ns-size(Qr,2)));
case 'FFTx',
    if size(XYZ,1)>2, m=Cffx(XYZ(1,:)',XYZ(2,:)',XYZ(3,:)'); 
    else, m=Cffx(XYZ(1,:)',XYZ(2,:)',zeros(size(XYZ,2),1)); end
    w=(1:32);
    Qr=exp(j*2*pi*m*w/60);
    Qr=[ones(size(XYZ,2),1), reshape(cat(1,real(Qr),imag(Qr)),[size(XYZ,2),2*size(Qr,2)])];
    Qr=Qr(:,1:Ns);
    Qr(:,1)=Qr(:,1)/norm(Qr(:,1)); 
    for n1=2:Ns, 
        Qr(:,n1)=Qr(:,n1)-Qr(:,1:n1-1)*Qr(:,1:n1-1)'*Qr(:,n1); 
        Qr(:,n1)=Qr(:,n1)/norm(Qr(:,n1)); 
    end
case 'FFT',
    lin=(XYZ-repmat(mean(XYZ,2),[1,size(XYZ,2)]))';
    nlin=max(abs(lin),[],1); lin=lin./nlin(ones(size(lin,1),1),:);
    w=(0:8)'; 
    idx1=1; idx2=1; for n1=1:4, 
        idx1=[idx1,2*n1*ones(1,2*n1-1),2*n1:-1:1,1:2*n1,(2*n1+1)*ones(1,2*n1+1)]; 
        idx2=[idx2,1:2*n1,2*n1*ones(1,2*n1-1),(2*n1+1)*ones(1,2*n1+1),2*n1:-1:1]; 
    end
    Qr=[]; for n1=1:length(idx1), Qr=[Qr,exp(j*2*pi*lin(:,1)*w(idx1(n1))).*exp(j*2*pi*lin(:,2)*w(idx2(n1)))]; end;
    Qr=[reshape(cat(1,imag(Qr),real(Qr)),[size(XYZ,2),2*size(Qr,2)])];
    Qr=Qr(:,1+(1:Ns));
    Qr(:,1)=Qr(:,1)/norm(Qr(:,1)); for n1=2:Ns, Qr(:,n1)=Qr(:,n1)-Qr(:,1:n1-1)*(Qr(:,1:n1-1)'*Qr(:,n1)); Qr(:,n1)=Qr(:,n1)/norm(Qr(:,n1)); end
case 'LIN',
    lin=(XYZ-repmat(mean(XYZ,2),[1,size(XYZ,2)]))';
    Qr=[ones(size(XYZ,2),1), lin, lin.^2, lin.^3, lin.^4, lin.^5];
    Qr=Qr(:,1:Ns);
    Qr(:,1)=Qr(:,1)/norm(Qr(:,1)); for n1=2:Ns, Qr(:,n1)=Qr(:,n1)-Qr(:,1:n1-1)*Qr(:,1:n1-1)'*Qr(:,n1); Qr(:,n1)=Qr(:,n1)/norm(Qr(:,n1)); end
case 'SVDspatial',
    lin=(XYZ-repmat(mean(XYZ,2),[1,size(XYZ,2)]))';
    [Ql,Dr,Qr]=svd(lin,0);
    lin=lin*Qr;
    Qr=[ones(size(XYZ,2),1), lin, lin.^2, lin.^3, lin.^4, lin.^5];
    Qr=Qr(:,1:Ns);
    Qr(:,1)=Qr(:,1)/norm(Qr(:,1)); for n1=2:Ns, Qr(:,n1)=Qr(:,n1)-Qr(:,1:n1-1)*Qr(:,1:n1-1)'*Qr(:,n1); Qr(:,n1)=Qr(:,n1)/norm(Qr(:,n1)); end
end
