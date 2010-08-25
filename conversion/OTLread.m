function [OTL, Mask]=OTLread(FileName);

% OTLREAD Reads .otl file
% OTL=OTLread(FileName)
% 	returns OTL structure
%		.Label			(Region labels)
%		.Parts			(Parts count per region)
%		.Size				(Image size)
%		.Region			(Array of structures .Seed, .Contour)
%

FileROI=which('ROI_Database_Labels.mat');
temp=loadfile(FileROI); if isempty(temp), OTL.Label{1}=''; else OTL=temp; end

fid=fopen(FileName,'r','ieee-be');
stop=0; idxOTL1=1; Prec_0='short';
OTL.Label{1}='';
OTL.Parts=zeros(1,length(OTL.Label)); 
%OTL.Parts(1)=0;
while ~stop,
   str=fgetl(fid);
   if ~isstr(str), stop=1;
   elseif ~isempty(str),
      switch upper(str),
      case 'END GDF HEADER'
         idxOTL2=OTL.Parts(idxOTL1)+1; OTL.Parts(idxOTL1)=idxOTL2;
         OTL.Region(idxOTL1).Seed{idxOTL2}=OTL_temp.Seed;
      case 'START POINTS'
         OTL_temp.Data=fread(fid,prod(OTL_temp.Size),Prec_0);
         OTL_temp.Data=reshape(OTL_temp.Data,fliplr(OTL_temp.Size)).';
      case 'END POINTS'
         OTL.Region(idxOTL1).Contour{idxOTL2}=OTL_temp.Data;
         idxOTL1=1;
      otherwise,
         [str_1, str_2]=strtok(str);
%         disp([str_1, ' ---- ', str_2]);
         switch upper(str_1),
         case 'ROW_NUM', OTL_temp.Size(1)=str2num(str_2);
         case 'COL_NUM', OTL_temp.Size(2)=str2num(str_2);
         case 'SEED', OTL_temp.Seed=str2num(str_2);
         case 'LABEL', 
            str_2(findstr(str_2,' '))=[]; 
            idxOTL1=strmatch(str_2,OTL.Label);
            if isempty(idxOTL1), 
               ButtonName=questdlg({'Warning!!', 'New information to be entered in ROI database.',['ROI: ',str_2]}, ...
                  'ROI Manager', ...
                  'Accept','Discard');
               switch(ButtonName),
               case 'Accept',
                  idxOTL1=length(OTL.Label)+1; 
                  OTL.Label{idxOTL1}=str_2;
                  OTL.Parts(idxOTL1)=0;
               end
                      
            end
         case 'TYPE', str_2(findstr(str_2,' '))=[]; Prec_0=str_2;
         case 'SIZE', OTL.Size=fliplr(str2num(str_2)); %x-y to y-x
         end
      end
   end
end
fclose(fid);
Label=OTL.Label;
save(FileROI,'Label');

% Creates Mask
if nargout>1,
   Mask=OTL2Mask(OTL);
end
