function [beta,g,P2,P0]=sap_gmem(x,f,beta0,varargin);
% GMEM 1-d Gaussian-Mixture EM
%
% [beta,g]=GMEM(x,f,beta0)
% min_{beta} {|g(x)-f(x;beta)|}
% where beta=[A,m,r]; 
% g=sum_i{1/sqrt(2*pi*r[i])*A[i]*exp(-(x-m[i])^2/r[i])};
% 

% 10/00
% alfnie@bu.edu
%

TOL=.005; % percentage change
options=strvcat(varargin{:});
sf=sum(f);
f=f(:)/sf;
x=x(:);
A=beta0(:,1);
m=beta0(:,2);
r=beta0(:,3);
Ni=length(A);
Nx=length(x);
dx=(x(end)-x(1))/(Nx-1);
minr=dx.^2;

beta=beta0; err=inf; while err>TOL,
   % E-Step
   % From model -> P(x|i)
   xm=(x(:,ones(1,Ni)).'-m(:,ones(1,Nx))).^2;
   P0=exp(-xm./(2*r(:,ones(1,Nx))))./sqrt(2*pi*r(:,ones(1,Nx)))*dx;
   P1=A(:,ones(1,Nx)).*P0;
   
   % From P(x|i) to P(i|x)
   g=sum(P1,1); 
   P2=P1./(eps+g(ones(1,Ni),:));
   
   % M-Step
   % P(i)
   A=eps+P2*f;
   % <x|i>
   m=(P2*(f.*x))./A;
   % <(x-m)^2|i>
   if strmatch('comvar',options), 	% common variance
      r=sum((P2.*xm)*f)*ones(Ni,1);
   else 										% default
      r=((P2.*xm)*f)./A;
   end
   r=max(minr,r);
   
   betanew=[A,m,r];
   err=abs(betanew-beta)./(eps+beta); err=max(err(:));
   beta=betanew;
end
%plot(x,f,'b',x,g,'r'); hold on; stem(m,A*dx./sqrt(2*pi*r)); hold off; drawnow
beta(:,1)=beta(:,1)*sf;
g=g*sf;

