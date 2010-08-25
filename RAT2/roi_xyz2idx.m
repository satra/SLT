function [idx,idx1,I,J] = roi_xyz2idx(xyz,Mxyz,Midx,dim)
% [IDX,IDX1,I,J] = ROI_XYZ2IDX(XYZ,MXYZ,MIDX,DIM) transforms the
% voxel positions from one space (XYZ) to another (IDX) given the
% transformation matrices MXYZ in XYZ space and MIDX in IDX
% space. IDX1 returns all the voxels in the transformed space while
% IDX contains the unique voxels. I,J are the mapping from IDX to
% IDX1 as defined in the Matlab function UNIQUE.
%
% See also: ROI_CREATE_ROI_DATA, UNIQUE

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

xyz = pinv(Midx)*Mxyz*[xyz,ones(size(xyz,1),1)]';
xyz = max(round(xyz(1:3,:)'),1);
idx1 = sub2ind(dim(1:3),xyz(:,1),xyz(:,2),xyz(:,3));
[idx,I,J] = unique(idx1);
