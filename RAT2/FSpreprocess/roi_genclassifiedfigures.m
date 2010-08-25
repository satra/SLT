function [fv,label,cols] = roi_genclassifiedfigures(subjdir,subjT1file)

SUBJECTS_DIR = getenv('SUBJECTS_DIR');
if isempty(SUBJECTS_DIR),
    error('FreeSurfer Environment not set');
end;

spm_defaults;

if nargin<2,
    try
      fn.T1file    = fullfile(SUBJECTS_DIR,subjimgdir);
      fn.T1file    = spm_get('Files',fn.T1file,'corr*.img');
    catch
      fnT1file = '';
      warning('Unable to locate T1 image');
    end
    %fn.T1file    = '/mnt/localhd2/satra/sp01/Subject.01/StructuralSeries.004/affine/';
    %fn.T1file    = spm_get('Files',fn.T1file,'w*.img');
else,
    fn.T1file = subjT1file;
end;

SUBJECTS_DIR = fullfile(SUBJECTS_DIR,subjdir);
FREESURF_DIR = getenv('FREESURFER_HOME');

% currently using *.orig because *.white gets screwed up if all the
% major edits are not performed
fn.lh_white  = fullfile(SUBJECTS_DIR,'surf','lh.white');
fn.rh_white  = fullfile(SUBJECTS_DIR,'surf','rh.white');

fn.lh_inflated  = fullfile(SUBJECTS_DIR,'surf','lh.inflated');
fn.rh_inflated  = fullfile(SUBJECTS_DIR,'surf','rh.inflated');

fn.lh_pial  = fullfile(SUBJECTS_DIR,'surf','lh.pial');
fn.rh_pial  = fullfile(SUBJECTS_DIR,'surf','rh.pial');

fn.lh_thick  = fullfile(SUBJECTS_DIR,'surf','lh.thickness');
fn.rh_thick  = fullfile(SUBJECTS_DIR,'surf','rh.thickness');

fn.lh_sph    = fullfile(SUBJECTS_DIR,'surf','lh.sphere');
fn.rh_sph    = fullfile(SUBJECTS_DIR,'surf','rh.sphere');

fn.lh_sphreg = fullfile(SUBJECTS_DIR,'surf','lh.sphere.reg');
fn.rh_sphreg = fullfile(SUBJECTS_DIR,'surf','rh.sphere.reg');

fn.lh_annot  = fullfile(SUBJECTS_DIR,'label','lh.aparc.annot');
fn.rh_annot  = fullfile(SUBJECTS_DIR,'label','rh.aparc.annot');

fn.lh_annot  = fullfile(SUBJECTS_DIR,'label','lh-aparc.annot');
fn.rh_annot  = fullfile(SUBJECTS_DIR,'label','rh-aparc.annot');

%fn.lh_annot  = fullfile(SUBJECTS_DIR,'label','lh.parctrain01.annot');
%fn.rh_annot  = fullfile(SUBJECTS_DIR,'label','rh.parctrain01.annot');

%fn.lh_annot  = fullfile(SUBJECTS_DIR,'label','lh.parc05.annot');
%fn.rh_annot  = fullfile(SUBJECTS_DIR,'label','rh.parc05.annot');

try
  Vhdr= spm_vol(fn.T1file);
catch
  warning('Cannot open T1file');
end
[v,f] = read_surf(fn.lh_pial);
v1 = v; %roi_surf2surf(v,Vhdr);  
fv = struct('faces',f+1,'vertices',v1);
[label,info,labelcols] = roifs_annotval2PUval(fn.lh_annot);


cols = labelcols;

%load('labelcols.spt','-MAT');
%cols = [0 0 0;labelcols];

fh(1) = figure;
showVertexValueDirect(fv,label);
colormap(cols);
view(90,0);
axis tight;
camlight headlight;
% print
fh(2) = figure;
showVertexValueDirect(fv,label);
colormap(cols);
view(-90,0);
axis tight;
camlight headlight;
% print

[v,f] = read_surf(fn.lh_inflated);
v1 = v; %roi_surf2surf(v,Vhdr);  
fv = struct('faces',f+1,'vertices',v1);
label = roifs_annotval2PUval(fn.lh_annot);

%load('labelcols.spt','-MAT');
%cols = [0 0 0;labelcols];

fh(3) = figure;
showVertexValueDirect(fv,label);
colormap(cols);
view(90,0);
axis tight;
camlight headlight;
% print
fh(4) = figure;
showVertexValueDirect(fv,label);
colormap(cols);
view(-90,0);
axis tight;
camlight headlight;
% print
uifig2subfig(fh);
colormap(cols);

if 0,
lh_thick = read_curv(fn.lh_thick);
[v,f] = read_surf(fn.lh_white);
v1 = roi_surf2surf(v,Vhdr);  
fv1 = struct('faces',f+1,'vertices',v1);
fv1 = st_preprocess(fv1);

VN = st_computeNormals(fv1);
v1 = v1 + VN.*repmat(lh_thick(:),1,3);
fv1 = struct('faces',f+1,'vertices',v1);

figure;
showVertexValueDirect(fv1,label);
colormap(cols);
view(90,0);
camlight headlight;
% print
figure;
showVertexValueDirect(fv1,label);
colormap(cols);
view(-90,0);
camlight headlight;
% print
end
