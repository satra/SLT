basedir = fileparts(which(mfilename));
RAT2_start;
addpath([basedir filesep '..' filesep 'ASAP']);
sap_command('Initialize');
