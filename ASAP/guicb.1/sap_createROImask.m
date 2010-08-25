function maskfile = sap_createROImask(sptfile,normT1file,varargin)
% SAP_CREATEROIMASK Creates an ROI mask in the same space as the structural data
%   This is a modification to the older routine in that it interpolates along the 
%   coronal dimension instead of only storing the slices that have been labelled.

%sptfile = 'corr_nsubject.09.Series.003.spt';
[path,name,xt] = fileparts(sptfile);
prefix = 'w';
if ~isempty(path),
    maskfile = [path,filesep,'ROImask_',name,'.img'];
    maskfile1 = [path,filesep,prefix,'ROImask_',name,'.img'];
else,
    maskfile = ['ROImask_',name,'.img'];
    maskfile1 = [prefix,'ROImask_',name,'.img'];
end;    

if nargin==3,
    return;
end;

load(sptfile,'-MAT','regdata','parcdata','fdata','offset','imgdata');
tmpmask = uint16(zeros(size(imgdata)));
sx = size(tmpmask,1);
sz = size(tmpmask,3);

midpt = round(size(imgdata,1)/2);
lrmask = 1;
val = 32000;
hproc = uiwaitbar('Getting labels');
for i=1:length(regdata),
    numlines = length(regdata(i).lines);
    if numlines>0 & ~(isempty(parcdata(i).lines)),
        mask = sap_getlabelmask(regdata(i),sx,sz,lrmask,midpt,val);
        if ~isempty(mask),
            tmpmask(:,i,:) = mask;
        end;
    end;
    uiwaitbar(i/length(regdata),hproc);        
end;
delete(hproc);

ROImask = zeros(size(tmpmask));
ROIlist = setdiff(unique(tmpmask(find(tmpmask(:)))),[3,32003]);
ROIlist = double(ROIlist(:)');
[PU,id] = sap_PUlist;

hproc = uiwaitbar('Interpolating ROIs');
for i = 1:length(ROIlist),
    ROI = ROIlist(i);
    if ~isempty(find((ROI==id) | (ROI-val)==id)),
        info = autocrop(tmpmask==ROI);
        a = ROI==tmpmask(info.x_prof(1):info.x_prof(end),info.y_prof,info.z_prof(1):info.z_prof(end));
        [xi,yi,zi] = meshgrid(info.y_prof(1):info.y_prof(end),info.x_prof(1):info.x_prof(end),info.z_prof(1):info.z_prof(end));
        [x,y,z] = meshgrid(info.y_prof(:)',info.x_prof(1):info.x_prof(end),info.z_prof(1):info.z_prof(end));
        b = ROI*(interp3(x,y,z,double(a),xi,yi,zi,'linear')>0);
        oldmask = ROImask(info.x_prof(1):info.x_prof(end),info.y_prof(1):info.y_prof(end),info.z_prof(1):info.z_prof(end));
        ROImask(info.x_prof(1):info.x_prof(end),info.y_prof(1):info.y_prof(end),info.z_prof(1):info.z_prof(end)) = oldmask+(oldmask==0).*b;
    end;
    uiwaitbar(i/length(ROIlist),hproc);
    %montage(permute(b>0,[3 1 4 2]));
    %pause;
end;
delete(hproc);

if nargin==2 & ~isempty(normT1file),
    V = spm_vol(normT1file);
else,
    load('dummyspmheader','V');
end;

ROImask2 = zeros(V.dim(1:3));
x_range = offset(1):(offset(1)+size(ROImask,1)-1);
y_range = offset(2):(offset(2)+size(ROImask,2)-1);
z_range = offset(3):(offset(3)+size(ROImask,3)-1);
ROImask2(x_range,y_range,z_range) = ROImask;

V.fname = maskfile1;
V.pinfo = [1 0 0]';
V.dim(4)= spm_type('uint16');
%ROImask2(1) = spm_type('uint16','maxval');
V2 = spm_create_vol(V);
for p=1:V2.dim(3)
    spm_write_plane(V2, ROImask2(:, :, p), p);
end
%spm_write_vol(V,ROImask2);
