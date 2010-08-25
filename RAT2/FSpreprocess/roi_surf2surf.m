function [v1,idx,v2] = roi_surf2surf(v,Vhdr)
% [V1,IDX] = ROI_SURF2SURF(V,VHDR) converts the Nx3 matrix V
% containing vertices into a space determined by the transformation
% matrix MAT contained in the analyze header VHDR. IDX contains the
% volume indices of the voxels corresponding to the vertices.
%
% See also: ROI_FS2RAT

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

sY = Vhdr.dim(1:3);
M  = Vhdr.mat;
% Assumes that the input brain was normalized and the only
% difference was in voxel size which is isotropic
M(1:3,4) = -(sY+1)'/(2/Vhdr.mat(1));
%M(1:3,4) = -sY'/2;

%M(1:3,4) = Vhdr.mat(1:3,4);

v1 = pinv(M)*[v,ones(length(v),1)]';v1 = v1(1:3,:)';
v2 = round(v1);
v1 =Vhdr.mat*[v1,ones(length(v1),1)]';v1 = v1(1:3,:)';

%[M,pinv(M)]
%[min(v1),max(v1)]

idx = sub2ind(abs(sY),v2(:,1),v2(:,2),v2(:,3));

