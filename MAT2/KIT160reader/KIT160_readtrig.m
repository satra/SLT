function T = KIT160_readtrig(fname,nchan)

% Internal function of sst_synchronize
% sst_readtrig_inline(fname, ngain)
% fname is the filename for SQD Raw Data
% channel is an array including Trigger Channels (96~97)

% Based on Satra's work
% 03/01/01,		Jia Liu,		Mass. Inst. of Tech.

datapoints = 192; % the total number of MEG channels, 128 for old MEG system.

fid = fopen (fname, 'r');

[offset, avg, gain, err] = KIT160_getinfo(fid);
if (err == -1),
   errordlg('Error in getting info');
   fclose(fid);
   return;
end

if avg
   datatype = 'float64';
   datasize = 8;
   str = sprintf('%s is an averaged SQD file, please select RAW SQD file.', fname);
   errordlg(str);
   return;
else
   datatype = 'int16';
   datasize = 2;
end
fseek(fid, offset, 'bof');

fdata = dir(fname);
slices = fix((fdata.bytes - offset) / (datasize * datapoints));

numChan = length(nchan);
if numChan > 1,
   if nchan(1) == nchan(2),
      numChan = 1;
   end
end

T = uint8(zeros(numChan,slices));
for i = 1:slices,
   R = fread (fid, datapoints, datatype);
   T(:,i) = uint8(R(nchan+1)/10);    
end

fclose(fid);
