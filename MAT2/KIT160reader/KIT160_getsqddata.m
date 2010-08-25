function data = KIT160_getsqddata(fname,pos, frlen)

% pos: Trigger Position, that is, onset of stimuli;
% frlen: the length of one epoch. 

fid = fopen (fname, 'r');
datapoints = 192; % 160 MEG channels.
nchans = 160;

% Set initial parameters based on where data segment
% starts and whether this is an averaged file

[offset, avg, gain, err] = KIT160_getinfo(fid);
if (err == -1),
   disp('Error in getting info');   
end;

if avg
   error('The file is averaged already! Choose a Raw SQD file.');
else
   datatype = 'int16';
   datasize = 2;
end

fseek(fid, offset, 'bof');

fseek(fid, pos*datapoints*datasize, 'cof');
tmpdata = fread(fid, frlen*datapoints, datatype);
tmpdata = reshape(tmpdata, datapoints, frlen);
data = tmpdata(1:nchans, :);

fclose(fid);
