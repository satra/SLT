% reads otl files and create MASK .img .hdr files
parentdir=pwd;
ROIdirread=['raw' filesep 'otl'];
ROIdirwrite='roi';
%StructHDR=which('ROIStruct.hdr');
Scale=[256 60 256];
Res=[1.0156 2.8 1.0156];
subnames=dir('Subject.*');

nsubs=length(subnames);
M=[diag(Res),-Res(:).*(Scale(:)/2);zeros(1,3),1];

for idxsub=1:nsubs,
   subname=subnames(idxsub).name;
   cd(subname); 
   subname=subname(:,9:end);
   disp(['Processing Subject ',subname]);
   
   if isempty(dir(ROIdirwrite)), mkdir(ROIdirwrite); end
   % Create reference structural
   names=dir(fullfile(ROIdirread,'*.img'));
   temp=sscanf(names(1).name,'%d_%d_%d.img');
   MaskStruct=[];
   for n1=1:3:length(names), %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      fh=fopen(fullfile(ROIdirread,sprintf('%d_%d_%d.img',temp(1),temp(2),n1)),'r');
      MaskStruct=cat(3,MaskStruct,fread(fh,Scale([1,3]),'uint16').');
      fclose(fh);
   end
   Scale(2)=size(MaskStruct,3); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   MaskStruct=permute(MaskStruct(end:-1:1,:,:),[2,3,1]);
   fh=fopen(fullfile(ROIdirwrite,'Subject_ROIStruct.img'),'w');
   fwrite(fh,MaskStruct(:),'uint16');
   fclose(fh);
   spm_hwrite(fullfile(ROIdirwrite,'Subject_ROIStruct.hdr'), [size(MaskStruct,1),size(MaskStruct,2),size(MaskStruct,3)], Res, 1, spm_type('uint16'), 0);
   save(fullfile(ROIdirwrite,'Subject_ROIStruct.mat'),'M');
   %   dos(['copy ', StructHDR, ' ', fullfile(ROIdirwrite,'Subject_ROIStruct.hdr')]);
   
   % Create Mask
   if 0, %exist(fullfile(ROIdirread,'info.mat'),'file'),
      temp=loadfile(fullfile(ROIdirread,'info.mat'),'-mat');
      Mask=temp.Mask; Labels=temp.Labels;
   else
      [OTL,Mask,Labels]=OTLreadset(...
         fullfile(ROIdirread,...
         'j'), Scale([3 1 2]));
      %      'jMGN'), Scale);
      save(fullfile(ROIdirread,'info.mat'),'Mask','Labels');
   end
   Mask=permute(Mask(end:-1:1,:,:),[2,3,1]);
   if size(MaskStruct,2)>size(Mask,2), Mask=cat(2,Mask,zeros([size(Mask,1),size(MaskStruct,2)-size(Mask,2),size(Mask,3)])); end
   fh=fopen(fullfile(ROIdirwrite,'Subject_ROI.img'),'w');
   fwrite(fh,Mask(:),'uint16');
   fclose(fh);
   spm_hwrite(fullfile(ROIdirwrite,'Subject_ROI.hdr'), [size(Mask,1),size(Mask,2),size(Mask,3)], Res, 1, spm_type('uint16'), 0);
   save(fullfile(ROIdirwrite,'Subject_ROI.mat'),'M');
   %   dos(['copy ', StructHDR, ' ', fullfile(ROIdirwrite,'Subject_ROI.hdr')]);
   
   cd ..
end
