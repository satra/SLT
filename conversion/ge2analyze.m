NUMIMAGES=60;			% sessions with 60 images are structural
MINIMAGES=100;			% sessions less than 100 images are HiRes, etc... (with more, they are functional)
NIMAGES=16;				% number of slices per TR in functional sessions
REMOVEFIRST=NIMAGES;	% remove first 16 images from each functional session 
OFFSET=14336;

parentdir=pwd;
subnames=dir('Subject.*');
nsubs=length(subnames);

for idxsub=1:nsubs,
   subname=subnames(idxsub).name;
   cd(subname); 
   cd raw
   subname=subname(:,9:end);
   disp(['Processing Subject ',subname]);
   for idxses=1:20,
      sesname=num2str(idxses,'%03d');
      found=dir([sesname,filesep,'I.*']);
      count=length(found);       
      if count,
         
         
         if count==NUMIMAGES, 		% STRUCTURAL DATA
            OutputDir=['..\StructuralSeries.',num2str(idxses,'%03d')];
            if isempty(dir(OutputDir)), mkdir(OutputDir); end
            disp(['Processing Subject ',subname, ' Directory ',sesname,' Structural']);
            
            % Read files
            temp=MRread([sesname,filesep,found(1).name]);
            Data=zeros([size(temp.Data), count]);
            Hdr1=temp.Hdr;
            Data(:,:,1)=temp.Data;
            for idxImage=2:count,
               temp=MRread([sesname,filesep,found(idxImage).name],Hdr1);
               Data(:,:,idxImage)=temp.Data;
            end
            Hdr2=MRheadread([sesname,filesep,found(count).name]);
            
            % Flip dimensions & save data
            [M,idx]=box2m(...
               [Hdr1.Image.ImTLHC_X Hdr1.Image.ImTLHC_Y Hdr1.Image.ImTLHC_Z],...
               [Hdr1.Image.ImTRHC_X Hdr1.Image.ImTRHC_Y Hdr1.Image.ImTRHC_Z],...
               [Hdr1.Image.ImBRHC_X Hdr1.Image.ImBRHC_Y Hdr1.Image.ImBRHC_Z],...
               [Hdr2.Image.ImTLHC_X Hdr2.Image.ImTLHC_Y Hdr2.Image.ImTLHC_Z],...
               [Hdr2.Image.ImTRHC_X Hdr2.Image.ImTRHC_Y Hdr2.Image.ImTRHC_Z],...
               [Hdr2.Image.ImBRHC_X Hdr2.Image.ImBRHC_Y Hdr2.Image.ImBRHC_Z],...
               Hdr1.Image.MatrixSize_X,Hdr1.Image.MatrixSize_Y,count);
            Data=permute(Data, idx);
            
            OutputName=['Subject', subname, '_Series',sesname];
            save([OutputDir, filesep, OutputName, '.mat'],'M');
            fh=fopen([OutputDir, filesep, OutputName, '.img'],'w');
            fwrite(fh,Data,'uint16');
            fclose(fh);
            spm_hwrite([OutputDir, filesep, OutputName], [size(Data,1),size(Data,2),size(Data,3)], [M(1,1),M(2,2),M(3,3)], 1, spm_type('uint16'), 0);

         elseif count<MINIMAGES, 		% HiRes & other
            OutputDir=['..\vStructuralSeries.',num2str(idxses,'%03d')];
            if isempty(dir(OutputDir)), mkdir(OutputDir); end
            disp(['Processing Subject ',subname, ' Directory ',sesname,' HiRes']);
            
            % Read files
            temp=MRread([sesname,filesep,found(1).name]);
            Data=zeros([size(temp.Data), count]);
            Hdr1=temp.Hdr;
            Data(:,:,1)=temp.Data;
            for idxImage=2:count,
               temp=MRread([sesname,filesep,found(idxImage).name], Hdr1);
               Data(:,:,idxImage)=temp.Data;
            end
            Hdr2=MRheadread([sesname,filesep,found(count).name]);
            
            % Flip dimensions & save data
            [M,idx]=box2m(...
               [Hdr1.Image.ImTLHC_X Hdr1.Image.ImTLHC_Y Hdr1.Image.ImTLHC_Z],...
               [Hdr1.Image.ImTRHC_X Hdr1.Image.ImTRHC_Y Hdr1.Image.ImTRHC_Z],...
               [Hdr1.Image.ImBRHC_X Hdr1.Image.ImBRHC_Y Hdr1.Image.ImBRHC_Z],...
               [Hdr2.Image.ImTLHC_X Hdr2.Image.ImTLHC_Y Hdr2.Image.ImTLHC_Z],...
               [Hdr2.Image.ImTRHC_X Hdr2.Image.ImTRHC_Y Hdr2.Image.ImTRHC_Z],...
               [Hdr2.Image.ImBRHC_X Hdr2.Image.ImBRHC_Y Hdr2.Image.ImBRHC_Z],...
               Hdr1.Image.MatrixSize_X,Hdr1.Image.MatrixSize_Y,count);
            Data=permute(Data, idx);
            OutputName=['Subject', subname, '_Series',sesname];
            save([OutputDir, filesep, OutputName, '.mat'],'M');
            fh=fopen([OutputDir, filesep, OutputName, '.img'],'w');
            fwrite(fh,Data,'uint16');
            fclose(fh);
            spm_hwrite([OutputDir, filesep, OutputName], [size(Data,1),size(Data,2),size(Data,3)], [M(1,1),M(2,2),M(3,3)], 1, spm_type('uint16'), 0);
 
 
         else, 					% FUNCTIONAL DATA
            OutputDir=['..\Series.',num2str(idxses,'%03d')];
            if isempty(dir(OutputDir)), mkdir(OutputDir); end
            
            % Read directories
            ndirs=0; countfiles=0;
            Filenames=[];
            while count,
               disp(['Processing Subject ',subname, ' Directory ',num2str(idxses+20*ndirs,'%03d'),' Functional']);
               if ~ndirs, 
                  idx=strmatch(['I.',num2str(REMOVEFIRST+1,'%03d')],strvcat(found.name));
                  if isempty(idx), disp('Warning!!!!: I did not found first image in set'); end
                  found=found(idx:end); count=length(found);
               end
               for n1=1:count, found(n1).name=[num2str(idxses+20*ndirs,'%03d'), filesep, found(n1).name]; end
               
               Filenames=[Filenames; found];
               countfiles=countfiles+count;
               ndirs=ndirs+1;
               found=dir([num2str(idxses+20*ndirs,'%03d'),filesep,'I.*']);
               count=length(found);
            end
            
            % Read files
            temp=MRread(Filenames(1).name);
            Data=zeros([size(temp.Data), NIMAGES]);
            Hdr1=temp.Hdr;
            Data(:,:,1)=temp.Data; idxImageVolume=1;
            for idxImage=2:countfiles,
               idxImageVolume=idxImageVolume+1;
               temp=MRread(Filenames(idxImage).name, Hdr1);
               Data(:,:,idxImageVolume)=temp.Data;
               if idxImageVolume==NIMAGES,
		            Hdr2=MRheadread(Filenames(idxImage).name);
                  % Flip dimensions & save data
                  [M,idx]=box2m(...
                     [Hdr1.Image.ImTLHC_X Hdr1.Image.ImTLHC_Y Hdr1.Image.ImTLHC_Z],...
                     [Hdr1.Image.ImTRHC_X Hdr1.Image.ImTRHC_Y Hdr1.Image.ImTRHC_Z],...
                     [Hdr1.Image.ImBRHC_X Hdr1.Image.ImBRHC_Y Hdr1.Image.ImBRHC_Z],...
                     [Hdr2.Image.ImTLHC_X Hdr2.Image.ImTLHC_Y Hdr2.Image.ImTLHC_Z],...
                     [Hdr2.Image.ImTRHC_X Hdr2.Image.ImTRHC_Y Hdr2.Image.ImTRHC_Z],...
                     [Hdr2.Image.ImBRHC_X Hdr2.Image.ImBRHC_Y Hdr2.Image.ImBRHC_Z],...
                     Hdr1.Image.MatrixSize_X,Hdr1.Image.MatrixSize_Y,NIMAGES);
                  Datasave=permute(Data, idx);
                  OutputName=['Subject', subname, '_Series',sesname, ...
                        '_T', num2str(idxImage/NIMAGES,'%04d')];
		            save([OutputDir, filesep, OutputName, '.mat'],'M');
                  fh=fopen([OutputDir, filesep, OutputName, '.img'],'w');
                  fwrite(fh,Datasave,'uint16');
                  fclose(fh);
		            spm_hwrite([OutputDir, filesep, OutputName], [size(Datasave,1),size(Datasave,2),size(Datasave,3)], [M(1,1),M(2,2),M(3,3)], 1, spm_type('uint16'), 0);
                  idxImageVolume=0;
               end
            end
         end
      end
   end
   cd(['..',filesep,'..']);
end

