function surfstruct = mat_gensurface01(origT1file, normT1file,normtrans, subjdir)
% SURFSTRUCT = MAT_GENSURFACE01(ORIGT1FILE,NORMT1FILE,NORMTRANS,SUBJDIR) generates
% the skull surface and the left and right cortical surfaces in the
% same space as the original T1 file

% Satrajit S Ghosh
% (c) SpeechLab, Boston University

% Parameters:
skull_isoval = 12;    % look at volume data to determine this value
isoval       = 0.5;  % Leave this as is. determines the isoval for
                     % a binary volume
surf_pos     = 0.5;  % 0 gray-white, 1 gray-csf
flipval      = 0;    % should generally be zero but this data set is
                     % from old data
dec_val      = 0.9; % amount of decimation (0,1)
pres_topo    = 1;    % preserve topology
regular_decim= 1;    % Use regular decimation (0) or pro decimation (1)

spm_defaults;

% Step 1. Generate skull surface
V = spm_vol(origT1file);
Y = spm_read_vols(V);
Y = (Y>skull_isoval);

disp('done smoothing extract skull');
fv = vtkIsoSurface(double(Y),int32(size(Y)),isoval,0);
fv.vertices = (V.mat(1:3,:)*[fv.vertices';ones(1,length(fv.vertices))])';
surfstruct.skull = fv;

% Load transformation information
normV   = spm_vol(normT1file);
affineM = load(normtrans,'-MAT');

% For each hemisphere convert freesurfer surfaces to native format
surfstruct.lh = freesurfer2native(subjdir,'lh',surf_pos,normV,affineM,flipval);
surfstruct.rh = freesurfer2native(subjdir,'rh',surf_pos,normV,affineM,flipval);

% Step 6. Decimate all surfaces
if regular_decim
    surfstruct.skull = vtkMDecimate(surfstruct.skull.vertices,int32(surfstruct.skull.faces), ...
				    dec_val,pres_topo,0);
    surfstruct.lh = vtkMDecimate(surfstruct.lh.vertices,int32(surfstruct.lh.faces), ...
				 dec_val,pres_topo,0);
    surfstruct.rh = vtkMDecimate(surfstruct.rh.vertices,int32(surfstruct.rh.faces), ...
				 dec_val,pres_topo,0);
else,
    surfstruct.skull = vtkMDecimatePro(surfstruct.skull.vertices,int32(surfstruct.skull.faces), ...
				       dec_val,pres_topo,0);
    surfstruct.lh = vtkMDecimatePro(surfstruct.lh.vertices,int32(surfstruct.lh.faces), ...
				    dec_val,pres_topo,0);
    surfstruct.rh = vtkMDecimatePro(surfstruct.rh.vertices,int32(surfstruct.rh.faces), ...
				    dec_val,pres_topo,0);
end;

% Step 7. Create a combined surface
surfstruct.both.vertices = ...
    [surfstruct.lh.vertices;surfstruct.rh.vertices];
surfstruct.both.faces = ...
    [surfstruct.lh.faces;length(surfstruct.lh.vertices)+surfstruct.rh.faces];


function surf = freesurfer2native(subjdir,surfside,surf_pos,normhdr,affineM,flip)
% Convert the freesurfer surface to the native space of the
% original T1 image.

SUBJECTS_DIR = getenv('SUBJECTS_DIR');
if isempty(SUBJECTS_DIR),
    error('FreeSurfer Environment not set');
end;

SUBJECTS_DIR = fullfile(SUBJECTS_DIR,subjdir);
FREESURF_DIR = getenv('FREESURFER_HOME');

surffile     = fullfile(SUBJECTS_DIR,'surf',[surfside,'.white']);
thickfile    = fullfile(SUBJECTS_DIR,'surf',[surfside,'.thickness']);

% Step 2. Read in the freesurfer cortical surfaces and convert the
% vertices to mm space of the normalized analyze image from which
% the surface was created
[v,f] = read_surf(surffile);
v = roi_surf2surf(v,normhdr);
mean(v)
if flip,
    v(:,1) = -v(:,1);
    f = f(:,[2 1 3]); %change vertex order so that normals still
                      %point outward
end
surf =struct('faces',f+1,'vertices',v);

% Step 3. Read the cortical thickness and generate a surface at the
% value of the parameter surf_pos
thick = read_curv(thickfile);
thick = thick(:);
surf_p = preprocess(surf);
VN = computeNormals(surf_p);
clear surf_p
surf.vertices = surf.vertices+surf_pos*(thick(:,ones(1,3)).*VN);

% Step 4. Use the affine transform matrix in normtrans to convert
% the surface to its native space coregistered with the skull
% surface generated above. 

p = affineM;
try,
% spm99
transform = p.MF*p.Affine*inv(p.MG);
surf.vertices = (transform(1:3,:)*[surf.vertices';ones(1,size(surf.vertices,1))])';
catch,
% spm2
transform = p.VF.mat*p.Affine*inv(p.VG.mat);
surf.vertices = (transform(1:3,:)*[surf.vertices';ones(1,size(surf.vertices,1))])';
end;
