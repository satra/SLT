function [pos,avg,amp,err] = KIT160_getinfo(fid)

% [pos,avg,amp] = get_meg_info96(fid)
% fid must be an opened file id (readable binary), 
% pos is the binary offset in the sqd file and
% avg is 0 for raw, 1 for averaged data
% In case of error, -1 is returned for the thing that 
% caused the error.
% get amplifier info (offset, then actual amp info)

% ??/??/1999	David Clark

err = 0;

if fseek(fid, 112, 'bof') == -1
   disp(ferror(fid));
   amp = -1; 
   err = -1;
   return
end
[amp_offset, count] = fread(fid, 1, 'uint16');
if count ~= 1
   disp(ferror(fid));
   amp = -1;
   err = -1;
   return
end

if fseek(fid, amp_offset, 'bof') == -1
   disp(ferror(fid));
   amp = -1;
   err = -1
   return
end
[amp_code, count] = fread(fid, 1, 'uint16');
if count ~= 1
   disp(ferror(fid));
   amp = -1;
   err = -1;
   return
end

% The input gain is stored in the 11th and 12th bits.  If you
% do the math, this is 6144 in decimal (MATLAB won't allow
% hex or octal representations which would look much nicer).

iamp_code = bitand(amp_code, 6144);
iamp_code = bitshift(iamp_code, -11);

switch iamp_code
case 0
   iamp = 1;
case 1
   iamp = 2;
case 2
   iamp = 5;
case 3
   iamp = 10;
end

% The output gain is stored in bits 0 to 2.  Math is the same.

oamp_code = bitand(amp_code, 7);

switch oamp_code
case 0
   oamp = 1;
case 1
   oamp = 2;
case 2
   oamp = 5;
case 3
   oamp = 10;
case 4
   oamp = 20;
case 5
   oamp = 50;
case 6
   oamp = 100;
case 7
   oamp = 200;
end

amp = oamp * iamp;

% find whether averaged 

if fseek(fid, 128, 'bof') == -1
   disp(ferror(fid));
   avg = -1;
   err = -1;
   return
end
[acq_offset, count] = fread(fid, 1, 'uint16');
if count ~= 1
   disp(ferror(fid));
   avg = -1;
   err = -1;
   return
end

if fseek(fid, acq_offset, 'bof') == -1
   disp(ferror(fid));
   err = -1;
   avg = -1;
   return
end
[acq, count] = fread(fid, 1, 'uint16');
if count ~= 1
   disp(ferror(fid));
   err = -1;
   avg = -1;
   return
end

% For now I am ignoring whether a file was averaged or evoked,
% Support could be put in here.

switch acq
case 1 % Continuous, Raw
   avg = 0;
case 2 % Evoked, Averaged
   avg = 1;
case 3 % Evoked, Raw
   avg = 0;
end

% either get raw data offset

if avg == 0
   if fseek(fid, 144, 'bof') == -1
      disp(ferror(fid));
      pos = -1; 
      avg = -1;
      return
   end
   [pos, count] = fread(fid, 1, 'uint16');
   if count ~= 1
      disp(ferror(fid));
      pos = -1; 
      avg = -1;
      return
   end

% or get averaged data offset

elseif avg == 1
   if fseek(fid, 160, 'bof') == -1
      disp(ferror(fid));
      pos = -1; 
      avg = -1;
      return
   end
   [pos, count] = fread(fid, 1, 'uint16');
   if count ~= 1
      disp(ferror(fid));
      pos = -1; 
      avg = -1;
      return
   end
end

