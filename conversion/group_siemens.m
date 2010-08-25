%function group_siemens

imagespergroup = 2;
numslices = 30;

DIRNAMES=dir('Subject.*');
Ndirs=length(DIRNAMES);

pdir = pwd;
for ndir=1:Ndirs,
    cd(DIRNAMES(ndir).name);
    hiresseries = dir('HiResSeries.*');
    boldseries = dir('Series.*');
    dirseries = [hiresseries;boldseries];
    Nseries = length(dirseries);
%    mkdir('Olddata');
%    copydest = [pwd filesep 'Olddata' filesep];
    for nseries=1:Nseries,
        cd(dirseries(nseries).name);
        dirimages = dir('Subject.*_T*.img');
        Nimages = length(dirimages);
        % for T1 epi and functional runs only
        Nvolumes = Nimages/imagespergroup;
        if Nvolumes>=1,
            Nvolumes = round(Nvolumes);
            disp(['Grouping: ' dirseries(nseries).name]);
            for nvolumes = 1:Nvolumes,
                Y = [];
                imgprefix = strtok(dirimages(1).name,'_');
                for nimg = 1:imagespergroup,
                    V = spm_vol(dirimages((nimg-1)*Nvolumes+nvolumes).name);
                    tmp = spm_read_vols(V);
                    Y(:,:,(nimg-1)*size(tmp,3)+[1:size(tmp,3)]) = tmp;
%                     [fpath,fname,fext] = fileparts(dirimages((nimg-1)*Nvolumes+nvolumes).name);
%                     copyfile([fname '.img'],copydest);
%                     copyfile([fname '.hdr'],copydest);
%                     copyfile([fname '.mat'],copydest);
%                     delete([fname '.img']);
%                     delete([fname '.hdr']);
%                     delete([fname '.mat']);
                end;
                Y = Y(:,:,1:numslices);
                V.fname = sprintf('%s_VT%05d.img',imgprefix,nvolumes);
                V.dim = [size(Y) 4];
                disp(['Writing file: ',V.fname]); 
                spm_write_vol(V,Y);
            end;
        else,
            disp(['structural found: ' dirseries(nseries).name]);
        end;
        cd('..');
    end;
    cd(pdir);    
end;
