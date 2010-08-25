function vox_idx = rave_mm2vox(verts,dim,vox)
% RAVE_MM2VOX Returns voxels corresponding to vertices of s surface/patch
%   A = RAVE_MM2VOX(V,D,X) returns the voxel index into a volume whose
%   dimensions are given by D of a list of vertices V. X is the size of the
%   voxel in each direction

%Map vertices to voxels
%verts = round(verts./vox(ones(length(verts),1),:));
verts = round(pinv(vox)*[verts';ones(1,length(verts))])';

verts(:,1) = max(1,min(verts(:,1),dim(1)));
verts(:,2) = max(1,min(verts(:,2),dim(2)));
verts(:,3) = max(1,min(verts(:,3),dim(3)));

vox_idx = sub2ind(dim(1:3),verts(:,1),verts(:,2),verts(:,3));
