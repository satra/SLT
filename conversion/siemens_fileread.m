function [data, hdr]=siemens_fileread(fname);
hdr=siemens_headread(fname);
fh=fopen(fname,'r','b'); 
fseek(fh, 6144, 'bof'); data=fread(fh,'uint16');
fclose(fh);
