function maskfile = roi_FS2RAT(subjdir,subjT1file)
% MASKFILE = ROI_FS2RAT(SUBJDIR,SUBJT1FILE) converts the
% automatically classified FreeSurfer surface into a mask file that
% can be used for ROI analyses. This function is called by
% ROI_RAT2FS with the appropriate parameters. SUBJDIR refers to the
% subject directory inside the folder called SURFER_SUBJECTS. The
% SUBJT1FILE is used to determine the volume and voxel dimensions
% for that subject and how to map the center of the FreeSurfer
% volume to the corresponding center of the SUBJT1FILE volume.
%
% See also: ROI_RAT2FS, ROI_SURFLABEL2MASK, ROI_ANNOT2LABEL,
% ROI_SURF2SURF 

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Requirements
% lh and rh . white,thickness, and sphere/sphere.reg 

% source ~/freesurfer_dev/FreeSurferEnv.csh
% addpath ~/software/matlabtools
% addpath ~/software/spm2b
% addpath ~/software/RAT2
% addpath ~/software/geometry

%subjdir    = 'sp01subj.01';   % CHANGE 1 FreeSurfer directory
%subjimgdir = 'sub01';      % CHANGE 2 Analyze image directory
maxval     = -1;           % CHANGE 3 Brightnessmax lower increases
                           % brightness 
alpha      = 1;            % CHANGE 4 Transparency value 0-1[opaque]

SUBJECTS_DIR = getenv('SUBJECTS_DIR');
if isempty(SUBJECTS_DIR),
    error('FreeSurfer Environment not set');
end;

spm_defaults;

if nargin<2,
    fn.T1file    = fullfile(SUBJECTS_DIR,subjimgdir);
    fn.T1file    = spm_get('Files',fn.T1file,'corr*.img');
    %fn.T1file    = '/mnt/localhd2/satra/sp01/Subject.01/StructuralSeries.004/affine/';
    %fn.T1file    = spm_get('Files',fn.T1file,'w*.img');
else,
    fn.T1file = subjT1file;
end;

SUBJECTS_DIR = fullfile(SUBJECTS_DIR,subjdir);
FREESURF_DIR = getenv('FREESURFER_HOME');

% currently using *.orig because *.white gets screwed up if all the
% major edits are not performed
fn.lh_white  = fullfile(SUBJECTS_DIR,'surf','lh.orig');
fn.rh_white  = fullfile(SUBJECTS_DIR,'surf','rh.orig');

fn.lh_pial  = fullfile(SUBJECTS_DIR,'surf','lh.pial');
fn.rh_pial  = fullfile(SUBJECTS_DIR,'surf','rh.pial');

fn.lh_thick  = fullfile(SUBJECTS_DIR,'surf','lh.thickness');
fn.rh_thick  = fullfile(SUBJECTS_DIR,'surf','rh.thickness');

fn.lh_sph    = fullfile(SUBJECTS_DIR,'surf','lh.sphere');
fn.rh_sph    = fullfile(SUBJECTS_DIR,'surf','rh.sphere');

fn.lh_sphreg = fullfile(SUBJECTS_DIR,'surf','lh.sphere.reg');
fn.rh_sphreg = fullfile(SUBJECTS_DIR,'surf','rh.sphere.reg');

fn.lh_annot  = fullfile(SUBJECTS_DIR,'label','lh-aparc.annot');
fn.rh_annot  = fullfile(SUBJECTS_DIR,'label','rh-aparc.annot');

fn.labels    = fullfile(FREESURF_DIR,'ASAP_labels.txt');

fn.aseg      = fullfile(SUBJECTS_DIR,'mri','aseg.mgz');
fn.asegspm   = fullfile(SUBJECTS_DIR,'mri','asegspm.img');
fn.asegspm2   = fullfile(SUBJECTS_DIR,'mri','asegspm2.img');
fn.likevol   = fullfile(SUBJECTS_DIR,'mri','orig','001.mgz');
fn.aseglabels= fullfile(FREESURF_DIR,'tkmeditColorsCMA');

% Step 1  Convert annotated file from classifier to PUidx
d.lh_annot = read_annotation(fn.lh_annot);
d.rh_annot = read_annotation(fn.rh_annot);

% label2annot
[id,nm,rr,gg,bb,dum] = textread(fn.labels,'%d%s%d%d%d%d');
for i=1:length(id),
    rgbval = hex2dec(fliplr([fliplr(dec2hex(rr(i),2)),...
		     fliplr(dec2hex(gg(i),2)),...
		     fliplr(dec2hex(bb(i),2))]));
    PU2A(i,1) = id(i);
    PU2A(i,2) = rgbval;
end

d.lh_PUid = roi_annot2label(d.lh_annot,PU2A);
d.rh_PUid = roi_annot2label(d.rh_annot,PU2A);

% Step 2  Convert surface to mm space of original structural file
[v,f] = read_surf(fn.lh_white);
v = roi_surf2surf(v,spm_vol(fn.T1file));
d.lh_white =struct('faces',f+1,'vertices',v);

[v,f] = read_surf(fn.rh_white);
v = roi_surf2surf(v,spm_vol(fn.T1file));
d.rh_white =struct('faces',f+1,'vertices',v);

[v,f] = read_surf(fn.lh_pial);
v = roi_surf2surf(v,spm_vol(fn.T1file));
d.lh_pial =struct('faces',f+1,'vertices',v);

[v,f] = read_surf(fn.rh_pial);
v = roi_surf2surf(v,spm_vol(fn.T1file));
d.rh_pial =struct('faces',f+1,'vertices',v);

% FreeSurfer vertex normals and thickness along those normals (not a true normal)
d.lh_FSVN = d.lh_pial.vertices - d.lh_white.vertices;
d.lh_pseudothick = sqrt(sum(d.lh_FSVN.^2,2));
d.lh_FSVN = d.lh_FSVN./repmat(d.lh_pseudothick,1,3);
d.rh_FSVN = d.rh_pial.vertices - d.rh_white.vertices;
d.rh_pseudothick = sqrt(sum(d.rh_FSVN.^2,2));
d.rh_FSVN = d.rh_FSVN./repmat(d.rh_pseudothick,1,3);

% Step 3  Read thickness information for the surface
d.lh_thick = min(read_curv(fn.lh_thick),10);
d.rh_thick = min(read_curv(fn.rh_thick),10);

% Step 4  Generate indices for the cortical ribbon in the voxel
% space
[d.mask,vmasklh] = roi_surflabel2mask(d.lh_white,spm_vol(fn.T1file), ...
			       d.lh_PUid,d.lh_thick);
%[d.mask,vmasklh] = roi_surflabel2mask(d.lh_white,spm_vol(fn.T1file), ...
%			       d.lh_PUid,d.lh_pseudothick,d.lh_FSVN);
d.mask(find(d.mask(:)==3)) = 0;
d.mask = 32000+d.mask;
d.mask(find(d.mask(:)==32000)) = 0;

[mask2,vmaskrh] = roi_surflabel2mask(d.rh_white,spm_vol(fn.T1file), ...
			       d.rh_PUid,d.rh_thick);
%[mask2,vmaskrh] = roi_surflabel2mask(d.rh_white,spm_vol(fn.T1file), ...
%			       d.rh_PUid,d.rh_pseudothick,d.rh_FSVN);
d.mask = d.mask + (d.mask==0).*mask2;
d.mask(find(d.mask(:)==3)) = 0;

%vmask = vmask1 + (~vmask1).*vmask2;

% Step 4a Create subcortical mask

% convert aseg to analyze
cmd = sprintf('mri_convert -ot spm --like %s %s %s',fn.likevol,fn.aseg,fn.asegspm2);
system(cmd);
%cmd = sprintf('mri_convert -it spm -ot spm --like %s %s %s',fn.T1file,fn.asegspm,fn.asegspm2);
%system(cmd);

% label2annot
[id,nm,rr,gg,bb,dum] = textread(fn.aseglabels,'%d%s%d%d%d%d');
load('aseg2sap_map.spt','-mat');
% aseg2sap = [...
%     4,32204;...
%     5,32205;...
%     7,32207;...
%     8,32208;...
%     10,32210;...
%     11,32211;...
%     12,32212;...
%     13,32213;...
%     17,32217;...
%     18,32218;...
%     26,32226;...
%     28,32228;...
%     16,32216;...
%     16,216;...
%     43,204;...
%     44,205;...
%     46,207;...
%     47,208;...
%     49,210;...
%     50,211;...
%     51,212;...
%     52,213;...
%     53,217;...
%     54,218;...
%     58,226;...
%     60,228];

Vaseg = spm_vol(fn.asegspm2);
Yaseg = spm_read_vols(Vaseg);
for a0=1:size(aseg2sap,1),
  idx = find(Yaseg(:)==aseg2sap(a0,1));
  d.mask(idx) = aseg2sap(a0,2);
end

%[TODO] reparcellate cerebellum

% Step 5  Create transparent overlay of autoparced PUs on
% structural

Vhdr= spm_vol(fn.T1file);
Y   = spm_read_vols(Vhdr);
if maxval == -1,
    Y1  = repmat(min(Y(:)/max(Y(:)),1),1,3);
else,
    Y1  = repmat(min(Y(:)/maxval,1),1,3);         
end
Y1 = round(512*Y1)/512;
idx = repmat(d.mask(:)>0,1,3);
load('labelcols.spt','labelcols','-MAT');
cols = [0,0,0;labelcols];
mask = d.mask(:);
mask = (mask>32000).*(mask-32000)+(mask<32000).*mask;
mask = cols(mask+1,:);

mask = (1-idx).*Y1 + idx.*(alpha*mask + (1-alpha)*Y1);
[map,I,J] = unique(mask,'rows');
mask = reshape(J,size(Y));
d.overlay = mask;
try
    %colormap(map);image(squeeze(mask(:,108,:))');
    %axis xy;axis square;

    figh = figure('doublebuffer','on');
    colormap(map);
    for i=1:size(d.overlay,2),
	image(squeeze(d.overlay(:,i,:))');
	axis xy;axis square;
	drawnow;
    end;
    close(figh);
catch,
    warning('Display not active');
end;

% Step 6
Vhdr = spm_vol(fn.T1file);
dsph.idx2sph = NaN*zeros(prod(Vhdr.dim(1:3)),3);

[vsph,f] = read_surf(fn.lh_sph);
%v = d.lh_white.vertices;
%v1    = round(pinv(Vhdr.mat)*[v,ones(length(v),1)]');
%v1    = v1(1:3,:)';
%dsph.lh_vidx  = sub2ind(Vhdr.dim(1:3),v1(:,1),v1(:,2),v1(:,3));
%dsph.idx2sph(dsph.lh_vidx,:) = vsph;
vidx = find(vmasklh(:));
dsph.lh_idx = vidx;
dsph.lh_vert= vmasklh(vidx);
dsph.idx2sph(vidx,:) = vsph(vmasklh(vidx),:); 

[vsph,f] = read_surf(fn.rh_sph);
%v = d.rh_white.vertices;
%v1    = round(pinv(Vhdr.mat)*[v,ones(length(v),1)]');
%v1    = v1(1:3,:)';
%dsph.rh_vidx  = sub2ind(Vhdr.dim(1:3),v1(:,1),v1(:,2),v1(:,3));
%dsph.idx2sph(dsph.rh_vidx,:) = vsph;
vidx = find(vmaskrh(:));
NaNidx = find(isnan(sum(dsph.idx2sph,2)));
vidx = intersect(vidx,NaNidx);
dsph.rh_idx = vidx;
dsph.rh_vert= vmaskrh(vidx);
dsph.idx2sph(vidx,:) =  vsph(vmaskrh(vidx),:); 

save(fullfile(SUBJECTS_DIR,['SURF2RAT_',subjdir,'.mat']),'d','dsph','fn','map');

% Write the mask volume
subjpath = fileparts(subjT1file);

Vhdr.fname = fullfile(subjpath,['SURF2RAT_',subjdir,'.img']);
Vhdr.dim(4) = spm_type('uint16');
Vhdr.pinfo = [1,0,0]';
spm_write_vol(Vhdr,d.mask);

maskfile = Vhdr.fname;

% Write idx2sph mapping
save(fullfile(subjpath,['SURF2RAT_',subjdir,'_ID2SPH.mat']),'dsph');
