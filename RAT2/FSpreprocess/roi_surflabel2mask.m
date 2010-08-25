function [Y,Vmask] = roi_surflabel2mask(surf,Vhdr,PUid,thick,VN)
% [Y,VMASK] = ROI_SURFLABEL2MASK(SURF,VHDR,PUID,THICK) converts an
% annotated surface SURF (with annotation PUID) into a mask Y of
% volume size provided in VHDR.DIM. The thickness of the surface is
% specified in the parameter THICK which contains a scalar for each
% VERTEX in mm. The operation is performed by marching the
% annotated value along the vertex normal of the vertex with the
% constraint that an already assigned voxel cannot be
% reassigned. VMASK returns indices to the original vertex IDs,
% that is which vertex corresponds to a given voxel in the volume
% Y. 
%
% [Y,VMASK] = ROI_SURFLABEL2MASK(...,VN) allows you to provide your
% own vertex normals. 
%
% [NOTE: Currently a fixed thickness of 1.9mm of cortex is being
% used as the thickness file generated by FreeSurfer is not always accurate.
%
% See also: ROI_FS2RAT

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Preprocess the surface and compute the vertex normals
if (nargin<5)
    fv = st_preprocess(surf);
    VN = st_computeNormals(fv);
    if ~isempty(fv.lonevertidx),
	PUid(fv.lonevertidx) = [];
	thick(fv.lonevertidx) = [];
    end;
else,
    fv = surf;
    VN = VN./(repmat(sqrt(sum(VN.^2,2)),1,3));
end

nomorechanges = 1;

Y = zeros(Vhdr.dim(1:3));
Vmask = zeros(size(Y));
v = fv.vertices;
idx1 = length(find(Y(:)));

bthickness = 1;
if bthickness,
    stepsz = 0.1;
    multval = 0.6;
else
    stepsz = 0.25;
    multval = 1.9;
end
count = 0;

%while nomorechanges & (stepsz*count<=0.6)
while nomorechanges & (stepsz*count<=multval)
    % Generate indices to volume
    v1 = round(pinv(Vhdr.mat)*[v,ones(length(v),1)]');
    v1 = v1(1:3,:)';
    vidx = sub2ind(Vhdr.dim(1:3),v1(:,1),v1(:,2),v1(:,3));
    % [min(v1),max(v1)]

    % Update the locations with label
    Y(vidx) = (Y(vidx)==0).*PUid + Y(vidx);
    Vmask(vidx) = (Vmask(vidx)==0).*[1:length(v)]' + Vmask(vidx);

    %imagesc(squeeze(Y(:,109,:)));pause(0.5);

    count = count + 1;

    %update vertex coordinates
    if bthickness,
	v = v + stepsz*repmat(thick,1,3).*VN;
    else
	v = v + stepsz*VN;
    end

    idx2 = length(find(Y(:)));
    nomorechanges = ~(idx1==idx2);
    idx2 = idx1;
end
