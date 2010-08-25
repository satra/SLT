% $Id: freesurfer_start.m 118 2005-11-21 17:44:30Z satra $

SUBJECTS_DIR = getenv('SUBJECTS_DIR');
if isempty(SUBJECTS_DIR),
    disp(['Type: FSpath at shell prompt']);
    error('FreeSurfer Environment not set');
end;
FSURF_DIR = getenv('FREESURFER_HOME');

basedir = fileparts(which(mfilename));
addpath([basedir filesep '..' filesep 'SurfTools']);
RAT5_start;
addpath([basedir filesep '..' filesep 'FSTools']);
try
    addpath([FSURF_DIR filesep 'matlab']);
catch
    warning('FreeSurfer matlab directory does not exist');
end
