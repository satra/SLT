spm_defaults;

DIRNAMES=dir('minc.*');
Ndirs=length(DIRNAMES);

for ndir=1:Ndirs,
    name=DIRNAMES(ndir).name(6:end);
    if ~exist(name,'dir'), mkdir(name); end
    PWout=name;
    PWin=[DIRNAMES(ndir).name,filesep];
    
    %find all subdirectories
    SUBDIRNAMES=dir(PWin);
    SUBDIRNAMES=SUBDIRNAMES(find([SUBDIRNAMES.isdir]));
    
    Nsubdirs = length(SUBDIRNAMES);
    infostruct = [];
    for nsubdir=1:Nsubdirs,
        sname = SUBDIRNAMES(nsubdir).name;
        prefix = getserprefix(sname);
        if ~isempty(prefix),
            subdirs = dir([PWin,filesep,sname]);
            if length(subdirs)>2,
                subdirs = subdirs(3:end);
                [sl,si] = sort(str2num(char({subdirs.name}')));
                subdirs = subdirs(si);
            end;
            addinfo = 0;
            time_prefix = 'T';
            switch prefix,
            case 'Series',
                addinfo = 1;
            case 'StructuralSeries',
                time_prefix = '';
                addinfo = 1;
            case 'HiResSeries',
                addinfo = 1;
            end;
            if addinfo,
                for num=1:length(subdirs),
                    Fdir = [PWin,filesep,sname,filesep,subdirs(num).name,filesep];
                    mncfiles = dir([Fdir,'*.mnc']);
                    if length(mncfiles)>1,
                        disp([Fdir,': Strange number of minc files']);
                    end;
                    infostruct(end+1).ifile = [Fdir,mncfiles(1).name];
                    infostruct(end).dir = [PWout,filesep,prefix,'.',subdirs(num).name];
                    fname = [PWout,'.','Series','.',subdirs(num).name,'.img'];
                    infostruct(end).ofile = [infostruct(end).dir,filesep,fname];
                    infostruct(end).prefix = time_prefix;
                end;
            end;
        end;
    end;    
    for num=1:length(infostruct),
        disp(['Writing: ',infostruct(num).dir]);
        V = spm_vol(infostruct(num).ifile);
        if ~exist(infostruct(num).dir,'dir'), mkdir(infostruct(num).dir); end
        spm_write_4dvol(V,infostruct(num).ofile,infostruct(num).prefix);
    end;
end
