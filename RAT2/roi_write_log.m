function roi_write_log(str,varargin)
% ROI_WRITE_LOG Writes to stdout or a logfile. It is currently set
% to writing a file called RAT2.log in the current working directory.

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

disp(str);
fid = fopen('RAT2.log','at');
fprintf(fid,'%s\n',str);
fclose(fid);
