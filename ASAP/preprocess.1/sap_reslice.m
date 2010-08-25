function [V,mat] = reslice(PI,hld)
% FORMAT reslice(PI,PO,dim,mat,hld)
%   PI - input filename
%   PO - output filename
%   dim - 1x3 matrix of image dimensions
%   mat - 4x4 affine transformation matrix mapping
%         from vox to mm (for output image).
%         To define M from vox and origin, then
%             off = -vox.*origin;
%              M   = [vox(1) 0      0      off(1)
%                     0      vox(2) 0      off(2)
%                     0      0      vox(3) off(3)
%                     0      0      0      1];
%
%   hld - interpolation method.
%___________________________________________________________________________
% %W% John Ashburner %E%

VI          = spm_vol(PI);
VO          = VI;
vox = [1 1 1];

VO.dim(1:3) = [220 220 220];
origin = VO.dim(1:3)/2;
off = -vox.*origin;
mat   = [vox(1) 0      0      off(1)
    0      vox(2) 0      off(2)
    0      0      vox(3) off(3)
    0      0      0      1];
VO.mat      = mat;

V = zeros(VO.dim(1:3));
hproc = uiwaitbar('Reslicing');
for x3 = 1:VO.dim(3),
        M  = inv(spm_matrix([0 0 -x3 0 0 0 1 1 1])*inv(VO.mat)*VI.mat);
        V(:,:,x3)  = spm_slice_vol(VI,M,VO.dim(1:2),hld);
        uiwaitbar(x3/VO.dim(3),hproc);
end;
delete(hproc);