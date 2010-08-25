function MR=MRread(Filename, MRhdr);
% MRread Reads MR file
% MR=MRread(Filename [, MRhdr]);
%

if nargin<2, MR.Hdr=MRheadread(Filename);
else MR.Hdr=MRhdr; end

if isempty(MR.Hdr), MR=[]; return; end

fid=fopen(Filename,'r','ieee-be');
if fid==-1, MR=[]; return; end

fread(fid,MR.Hdr.Control.ImagePtr,'char');
MR.Data=fread(fid,MR.Hdr.Control.ImageWidth*MR.Hdr.Control.ImageHeight, ...
   ['int',num2str(MR.Hdr.Control.ImageDepth)]);
MR.Data=reshape(MR.Data,[MR.Hdr.Control.ImageWidth, MR.Hdr.Control.ImageHeight]).';
fclose(fid);


