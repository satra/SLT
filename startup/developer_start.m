SUBJECTS_DIR = getenv('SUBJECTS_DIR');
if isempty(SUBJECTS_DIR),
    disp(['Use: FSMatlab_dev to launch matlab']);
    error('FreeSurfer Environment not set');
end;

basedir = fileparts(which(mfilename));
addpath([basedir filesep '..' filesep 'utils']);

% modify the following lines to suit your system
%addpath([basedir filesep '..' filesep 'spm2']);
spm2_start;
addpath([basedir filesep '..' filesep 'SurfTools']);
addpath([basedir filesep '..' filesep 'RAT2' filesep 'ASAPpreprocess']);
addpath([basedir filesep '..' filesep 'RAT2' filesep 'FSpreprocess']);
addpath([basedir filesep '..' filesep 'RAT2' filesep 'ROIfig']);
addpath([basedir filesep '..' filesep 'RAT2' filesep 'verify']);
addpath([basedir filesep '..' filesep 'RAT2']);
addpath([basedir filesep '..' filesep 'aal']);
addpath([basedir filesep '..' filesep 'FSTools']);
%addpath([basedir filesep '..' filesep 'snpm2']);
%addpath([basedir filesep '..' filesep 'spmd2']);
