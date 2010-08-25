DIRNAMES=dir('raw.*');
Ndirs=length(DIRNAMES);

for ndir=1:Ndirs,
    name=DIRNAMES(ndir).name(5:end);
    if ~exist(name,'dir'), mkdir(name); end
    PWout=name;
    PWin=[DIRNAMES(ndir).name,filesep];
    
    % Get&sort file names
    names=dir([PWin,'*.ima']);
    names=strvcat(names(:).name);
    N=size(names,1);
    Sess=zeros(N,1); Runs=zeros(N,1); Scans=zeros(N,1);
    for n1=1:N, 
        [a,b]=strtok(names(n1,:),'-'); 	Sess(n1)=str2num(a);
        [a,b]=strtok(b(2:end),'-'); 		Runs(n1)=str2num(a);
        [a,b]=strtok(b(2:end),'.'); 		Scans(n1)=str2num(a);
    end
    InfoScan=[Sess Runs Scans];
    [InfoScan, idxnames]=sortrows(InfoScan);
    NInfoScan=size(InfoScan,1);
    idxSess0=[1; 1+find(InfoScan(2:end,1)~=InfoScan(1:end-1,1))]';
    idxRuns0=union(idxSess0,[1; 1+find(InfoScan(2:end,2)~=InfoScan(1:end-1,2))]);
    
    % Read&Transform files
    Nsess=length(idxSess0); 
    idxSess=[idxSess0, NInfoScan+1];
    for nsess=1:Nsess,
        idxRuns=idxRuns0(find(idxRuns0>=idxSess(nsess) & idxRuns0<idxSess(nsess+1)))';
        Nruns=length(idxRuns); 
        idxRuns=[idxRuns, idxSess(nsess+1)];
        for nruns=1:Nruns,
            disp([PWin,names(idxnames(idxRuns(nruns)),:)]);
            dataAll=[]; idxAll=0;
            for nscans=1:idxRuns(nruns+1)-idxRuns(nruns),
                [Data,hdr]=siemens_fileread(deblank([PWin,names(idxnames(idxRuns(nruns)+nscans-1),:)]));
                [M,idx,sM,Data]=siemens_header2m(hdr,Data);
                idx0=ones(1,3); sData=size(Data); idx0(1:length(sData))=(sData==1);
                OutputName1 = [getseriestypename(hdr),'.',num2str(nruns,'%03d')];
                if ~sum(idx0),
                    if Nsess>1, 
                        OutputName=['Session.',num2str(nsess,'%03d'),'.Series.',num2str(nruns,'%03d')];
                        OutputName1 = OutputName;
                    else 
                        OutputName=['Series.',num2str(nruns,'%03d')]; 
                    end
                    FileName=[PWout, filesep, OutputName1, filesep, PWout,'.',OutputName,'_T',num2str(nscans,'%05d')];
                    if isempty(dir(PWout)), mkdir(PWout); end; 
                    if isempty(dir([PWout,filesep,OutputName1])), mkdir(PWout,OutputName1), end
                    disp(['File Write ',FileName]);
                    fh=fopen([FileName,'.img'],'w');
                    fwrite(fh,Data,'uint16');
                    fclose(fh);
                    spm_hwrite([FileName,'.img'], [size(Data,1),size(Data,2),size(Data,3)], [M(1,1),M(2,2),M(3,3)], 1, spm_type('uint16'), 0, round([size(Data,1),size(Data,2),size(Data,3)]/2));
                    save([FileName, '.mat'],'M');
                elseif nscans==1 | find(idx0)==idxAll;
                    if nscans==1, hdrFirst=hdr; end
                    idxAll=find(idx0);
                    dataAll=cat(idxAll,dataAll,Data);
                else
                    disp('oops...'); dataAll=[];
                end
            end
            if ~isempty(dataAll),
                if Nsess>1, 
                    OutputName=['Session.',num2str(nsess,'%03d'),'.Series.',num2str(nruns,'%03d')];
                    OutputName1 = OutputName;
                else 
                    OutputName=['Series.',num2str(nruns,'%03d')]; 
                end
                FileName=[PWout, filesep, OutputName1, filesep, PWout, '.', OutputName];
                if isempty(dir(PWout)), mkdir(PWout); end; 
                if isempty(dir([PWout,filesep,OutputName1])), mkdir(PWout,OutputName1), end
                disp(['File Write ',FileName]);
                fh=fopen([FileName,'.img'],'w');
                fwrite(fh,dataAll,'uint16');
                fclose(fh);
                M=siemens_header2m(hdrFirst,[],nscans);
                spm_hwrite([FileName,'.img'], [size(dataAll,1),size(dataAll,2),size(dataAll,3)], [M(1,1),M(2,2),M(3,3)], 1, spm_type('uint16'), 0, round([size(dataAll,1),size(dataAll,2),size(dataAll,3)]/2));
                save([FileName, '.mat'],'M');
            end
        end
    end
    %         disp(InfoScan(idxRuns(nruns),:));
    %         disp(names(idxnames(idxRuns(nruns)),:));
end