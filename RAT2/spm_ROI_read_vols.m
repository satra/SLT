function [R,XYZ,gx]=spm_ROI_read_vols(Fimg,Fmask)
% spm_ROI_read_vols Get temporal data for each defined Region of Interest
%
% function [R,XYZ]=spm_ROI_read_vols(Fimg,Fmask)
%	Fimg,Fmask	:	File names of Functional(s) and Mask defining ROI
%	R			:   Cell array (one element for each ROI) with [Time x voxel] data
%	XYZ			:	Cell array (one element for each ROI) with [3 x voxel] xyz data
%

% alfnie@bu.edu
% 7/01
%

FACTOR = 1;                 % Scaling factor of Mask file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% !!!!!!!!!!!!!!!!!!! %%%%%%%%%%%%%%%
THR=1;                      % Remove out-of-brain voxels (globalmean/8 threshold)
Vmask=spm_vol(Fmask);
Vimg=spm_vol(Fimg);
%load(spm_ROI_input('files.name_roilabel'),'Label','-mat');
Label = sap_getLabels;
Nmask=length(Label);
idxRegion=strmatch('',Label,'exact'); idxRegion=setdiff(1:Nmask,idxRegion); % note: skip regions with an empty string label
Nimg=prod(size(Vimg));
dim=Vmask.dim(1:3);
R=cell([Nmask,1]); 
XYZ=cell([Nmask,1]);
M=Vimg(1).mat;

N=zeros(1,Nmask);		    % Number of pixels in each region
L=N;						% Number of pixels (in each slice of Fmask) in each region
MAXN=1000;
[XYZ{idxRegion}]=deal(zeros([3,MAXN]));
[R{idxRegion}]=deal(zeros([Nimg,MAXN]));
for nslice=1:dim(3),
   Mi=spm_matrix([0 0 nslice]);
   % Get Slice from IMAGE
   M1=M\Vmask.mat\Mi;
   msk=spm_slice_vol(Vmask,M1,dim(1:2),[0 0]);	% Get mask over nslice slice of Fimg(1)
   
   % Find index (in mask slice) to pixels for each region
   for nmask=idxRegion,	% note (skip region #0)
      idx{nmask}=find(round(FACTOR*msk)==nmask);
      L(nmask)=length(idx{nmask});
   end
   
   if any(L),
      % Get centers of regions
      for nmask=find(L),
         [x,y]=ind2sub(dim(1:2),idx{nmask});
         xyz=M*[x(:)';y(:)';nslice*ones(1,L(nmask));ones(1,L(nmask))];
         XYZ{nmask}(1:3,N(nmask)+(1:L(nmask)))=xyz(1:3,:);
      end
      
      for nimage=1:Nimg,
         % Get Slice from Fimg(nimage) in line with nslice slice of Fimg(1)
         M1=M\Vimg(nimage).mat\Mi;
         img=spm_slice_vol(Vimg(nimage),M1,dim(1:2),[1 0]);
         
         % Get pixels of Slice in each region
         for nmask=find(L),
            R{nmask}(nimage,N(nmask)+(1:L(nmask)))=img(idx{nmask});
         end
      end
   end
   N=N+L;
end

% Remove xtra space
for nmask=idxRegion,
    XYZ{nmask}=XYZ{nmask}(:,1:N(nmask));
    R{nmask}=R{nmask}(:,1:N(nmask));
end

% Thresholding mask
if nargout>2 | THR,
    gx=zeros(Nimg,1);
    for nimage=1:Nimg, gx(nimage)=spm_global(Vimg(nimage)); end
end
if THR,
    for n1=idxRegion, 
        if ~isempty(R{n1}),
            idx=find(all(R{n1}>repmat(gx/4,[1,size(R{n1},2)]),1)); 
            R{n1}=R{n1}(:,idx); XYZ{n1}=XYZ{n1}(:,idx); 
            [nill,idx]=sort(min(R{n1},[],1));
            R{n1}=R{n1}(:,idx(end:-1:1)); XYZ{n1}=XYZ{n1}(:,idx(end:-1:1));
        end
    end
end

