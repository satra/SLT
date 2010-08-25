function [params,f_hat,invf_hat,f_corr]=spm_ROI_fiterr_em(f,x0,minF,maxF);
% FITERR fit noise spectrum with gaussian+flat model
% [params,f_hat]=spm_ROI_fiterr(f,x0,minW,maxW)
% where f is the noise spectrum 
% fits the model f(w) = a1*exp(-1/2*(w/rho)^2) + a2
% in the frequency of interest window minF <= abs(w) <= maxF
% using a gaussian-mixture EM algortithm.
% spm_ROI_fiterr_em returns:
% params = [a1,a2,rho]  (estimated parameters)
% f_hat                 (estimated spectrum)
%
% Note: The noise spectrum is assumed to be obtained as follows:
%           e=Y-X*inv(X'*X)*X'*Y; (where Y is the temporal signal and X the matrix of temporal regressors)
% then      f  = mean(abs(fft(e).^2),2);
%           x0 = fft(X);
%           minF,maxF should be in the range 0 <= minF < maxF <= length(f)/2
% spm_ROI_fiterr_em will use the information in x0 to fillin
% the information of the original noise model that correlates
% with the regressors (and is missing from the residuals)
%

% alfnie@bu.edu
% 03/02

%invf_hat=ones(size(f)); params=[]; f_hat=[]; return;

TOL=1e-5;        % tolerance
MAXITER=1*1024;
Nx=length(f);
x=[0:ceil(Nx/2),-floor(Nx/2)+1:-1]';
sf=sum(f);
f=f(:)/sf;
x=x(:);
A=[1;1];        % Initial [a1,a2] values
m=[0;0];        % Gaussian mixture centers
r=[(maxF/4).^2;inf];   % Initial Gaussian mixture variances
Ni=length(A);
minr=max(1,minF.^2); 
idxminF=find(abs(x)<minF);
idxmaxF=find(abs(x)>maxF);
%x0=abs(x0);
x0=sum(abs(x0),2);
%x0=sum(x0,2); %%%
ix0=pinv(x0'*x0);

f0=f; niter=0; beta=[A,m,r]; err=inf; while err>TOL & niter<MAXITER,
   % E-Step
   % From model -> P(x|i)
   xm=(x(:,ones(1,Ni)).'-m(:,ones(1,Nx))).^2;
   P0=exp(-xm./(2*r(:,ones(1,Nx))))./min(Nx,sqrt(2*pi*r(:,ones(1,Nx))));
   P1=A(:,ones(1,Nx)).*P0;
   
   % From P(x|i) to P(i|x)
   g=sum(P1,1); 
   P2=P1./(eps+g(ones(1,Ni),:));
   
   % Fill-in estimated noise correlating with regressors
   %f=f0-abs(x0*(ix0*(x0'*sqrt(f0)))).^2+abs(x0*(ix0*(x0'*sqrt(g')))).^2; 
   f=f0-.1*x0*(ix0*(x0'*(f0-g'))); 
   % Fill-in estimated noise outside frequency of interest window
   f(idxminF)=g(idxminF); f(idxmaxF)=g(idxmaxF);
   
   % M-Step
   A_hat=eps+P2*f;                 % P(i)
   m_hat=(P2*(f.*x))./A;           % <x|i>
   r_hat=((P2.*xm)*f)./A;          % <(x-m)^2|i>
   r_hat=max(minr,r_hat);
   
   % Actualize parameters
   A=A_hat;
   r(1)=r_hat(1);
   betanew=[A,m,r];
   err=abs(betanew-beta)./(eps+beta); err=max(err(:));
   beta=betanew;
   niter=niter+1;
   %disp([beta(1,1),beta(2,1),beta(1,3)]);
   %plot(x,f0,'b.-',x,g,'r.-'); set(gca,'xtick',[-maxF,-minF,minF,maxF]); grid on; drawnow;   
end

beta(:,1)=beta(:,1)*sf;
g=g*sf;

params=[g(1),g(round(Nx/2)),sqrt(beta(1,3))];
f_hat=g(:);
invf_hat=1./(eps+f_hat(:));
f_corr=f(:)*sf;

if niter==MAXITER, disp('spm_ROI: Warning!. Maximum interation reached in noise estimation step.'); end
h=findobj('tag','spm_ROI_FitErr_em'); if isempty(h), h=figure('units','norm','color','k','tag','spm_ROI_FitErr_em','menu','none','position',[.1,.7,.2,.2]); else, figure(h); end;
h=plot(x,f0*sf,'b.',x,f_hat,'r.-',x(idxminF),f0(idxminF)*sf,'k.',x(idxmaxF),f0(idxmaxF)*sf,'k.',x(idxminF),f_hat(idxminF),'k.',x(idxmaxF),f_hat(idxmaxF),'k.'); set(h(3:end),'markeredgecolor',[.3,.3,.3]); set(gca,'xtick',[-maxF,-minF,minF,maxF],'xticklabel',[],'yticklabel',[],'xcolor','y','ycolor','y','color','k'); grid on; drawnow;
