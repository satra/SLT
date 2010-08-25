function MR=MRheadread(Filename);
% MRheadread Reads header of .MR file
% MR=MRheadread(Filename);
%

% note: every number is in bytes!!...

MAGICNUMBER=1229801286;
MR=[];

% CONTROL HEADER
PTR01={...
       'MagicNumber', 0, 1, 'int',...
       'ImagePtr', 4, 1, 'int',...
       'ImageWidth', 8, 1, 'int', ...
       'ImageHeight', 12, 1, 'int', ...
       'ImageDepth', 16, 1, 'int', ...
       'Compression', 20, 1, 'int',...
       'ImageHdr', 56, 1, 'int',...
       'ExamHdr', 132, 1, 'int',...
       'SeriesHdr', 140, 1, 'int',...
       'ImageHdr', 148, 1, 'int'};

% EXAM HEADER
PTR02={...
       'SuiteID', 0, 4, 'char', ...
       'ExamNumber', 8, 1, 'ushort', ...
       'PatientID', 84, 13, 'char', ...
       'PatientName', 97, 25, 'char', ...
       'PatientAge', 122, 1, 'short', ...
       'PatientSex', 126, 1, 'short', ...
       'ExamType', 305, 3, 'char'};

% SERIES HEADER
PTR03={...
       'SeriesNumber', 10, 1, 'short', ...
       'AnatomicalRef', 84, 3, 'char', ...
       'ScanProtocolName', 92, 25, 'char'};

% IMAGE HEADER
PTR04={...
       'ImageNumber', 12, 1, 'short', ...
       'SliceThickness', 26, 1, 'float', ...
       'MatrixSize_X', 30, 1, 'short', ...
       'MatrixSize_Y', 32, 1, 'short', ...
       'FoV_X', 34, 1, 'float', ...
       'FoV_Y', 38, 1, 'float', ...
       'ImageDim_X', 42, 1, 'float', ...
       'ImageDim_Y', 46, 1, 'float', ...
       'PixelSize_X', 50, 1, 'float', ...
       'PixelSize_Y',54, 1, 'float', ...
       'PixelDataID', 58, 14, 'char', ...
       'ImLocation', 126, 1, 'float', ...
       'ImCenter_X', 130, 1, 'float', ...
       'ImCenter_Y', 134, 1, 'float', ...
       'ImCenter_Z', 138, 1, 'float', ...
       'ImTLHC_X', 154, 1, 'float', ...
       'ImTLHC_Y', 158, 1, 'float', ...
       'ImTLHC_Z', 162, 1, 'float', ...
       'ImTRHC_X', 166, 1, 'float', ...
       'ImTRHC_Y', 170, 1, 'float', ...
       'ImTRHC_Z', 174, 1, 'float', ...
       'ImBRHC_X', 178, 1, 'float', ...
       'ImBRHC_Y', 182, 1, 'float', ...
       'ImBRHC_Z', 186, 1, 'float', ...
       'RepetitionTime', 194, 1, 'int', ...
       'InversionTime', 198, 1, 'int', ...
       'EchoTime', 202, 1, 'int', ...
       'NumberEchoes', 210, 1, 'short', ...
       'EchoNumber', 212, 1, 'short', ...
       'NEX', 218, 1, 'float', ...
       'PulseSequenceName', 308, 33, 'char', ...
       'CoilName', 362, 17, 'char'};



fid=fopen(Filename,'r','ieee-be');
if fid==-1, return; end

% Reads CONTROL HEADER
[DATA01, ptr]=fieldread(fid, PTR01);
if DATA01.MagicNumber~=MAGICNUMBER, disp('MRheadread: Wrong file type'); fclose(fid); return; end

% Reads EXAM HEADER
fread(fid,DATA01.ExamHdr-ptr,'char');
[DATA02, n]=fieldread(fid, PTR02);
ptr=DATA01.ExamHdr+n;

% Reads SERIES HEADER
fread(fid,DATA01.SeriesHdr-ptr,'char');
[DATA03, n]=fieldread(fid, PTR03);
ptr=DATA01.SeriesHdr+n;

% Reads IMAGE HEADER
fread(fid,DATA01.ImageHdr-ptr,'char');
[DATA04, n]=fieldread(fid, PTR04);

fclose(fid);
MR.Control=DATA01;
MR.Exam=DATA02;
MR.Series=DATA03;
MR.Image=DATA04;





function [DATA, ptr]=fieldread(fid, PTR)

DATA=[]; ptr=0;
for n1=1:length(PTR)/4,
   idx=4*(n1-1);
   fread(fid, PTR{idx+2}-ptr,'char');
   [temp,n]=fread(fid, PTR{idx+3}, PTR{idx+4});
   if n~=PTR{idx+3}, disp('MR hdr reader: Warning, unable to read field'); end
   switch(PTR{idx+4}),
      case {'char'}, eval(['DATA.',PTR{idx+1},'=char(bitand(abs(temp),127))'';']);
      otherwise, eval(['DATA.',PTR{idx+1},'=temp;']);
      end
   switch(PTR{idx+4}),
      case {'int','uint','float'}, ptr=PTR{idx+2}+n*4;
      case {'short','ushort'}, ptr=PTR{idx+2}+n*2;
      case {'char','uchar'}, ptr=PTR{idx+2}+n;
      otherwise, disp('ERROR: Not recognized numeric format'); ptr=PTR{idx+2}+2*n;
   end
end











