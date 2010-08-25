function leadfield = mat_getleadfield(srcloc,srcori)
% LEADFIELD = GETLEADFIELD(SRCLOC,SRCORI) generates the leadfield matrix
% for the KIT/MIT MEG system installed at MIT. This uses the 93 channel
% sensor configuration with a baseline of 0.05m. See CALCLEADF for a
% description of the inputs to this routine. 

% Satrajit S. Ghosh (satra@bu.edu)
% (c) SpeechLab, Boston University, 2003

% Get sensor information
[chans,sensloc,sensori] = mat_getChans('all',[]);

% Calculate leadfield
tic;leadfield = mat_calcleadf(srcloc,srcori,sensloc,sensori,0.05);toc;
