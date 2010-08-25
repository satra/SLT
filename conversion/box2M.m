function [M,idx]=box2M(TLHC1,TRHC1,BRHC1,TLHC2,TRHC2,BRHC2,nBT,nLR,n12)

M=[ ...
   (BRHC1(:)-TRHC1(:)),...
   (TRHC1(:)-TLHC1(:)),...
   (TLHC2(:)-TLHC1(:))];
M0=TLHC1(:);
n=[nBT nLR n12];
% sorts such that columns of M are in x,y,z direction (as vectors TLHC1,...)
[nill,idx]=max(abs(M));
for n1=1:3, if nill(n1)==min(abs(M(:,n1))), idx(n1)=setxor(1:3,idx(setxor(1:3,n1))); end; end
if idx(1)==idx(2) | idx(1)==idx(3) | idx(2)==idx(3), disp(idx); disp(M); M=[]; idx=[]; disp('box2M: Error!!'); 
else
   [nill,idx]=sort(idx);
   M=M(:,idx);
   n=n(idx);
   % creates affine transformation matrix M (centered at n/2)
%   % correct for sign (increasing x,y,z direction)
%   sM=sign(diag(M));
%   M0=M0+M'*(sM<0);
   % normalize
   M=M./n(ones(1,3),:);
%%   M(:,2)=M(:,2)-M(:,1)*(M(:,1)'*M(:,2)/max(eps,sum(abs(M(:,1)).^2)));
%%   M(:,3)=M(:,3)-M(:,1)*(M(:,1)'*M(:,3)/max(eps,sum(abs(M(:,1)).^2)));
%%   M(:,3)=M(:,3)-M(:,2)*(M(:,2)'*M(:,3)/max(eps,sum(abs(M(:,2)).^2)));
%   M=M./sM(:,ones(1,3));
   M=[[M M0-sum(M,2)]; [0 0 0 1]];
end
