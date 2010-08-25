function sap_normall(fnames,str)

for i=1:length(fnames),
    V = spm_vol(fnames{i});
    Y = spm_read_vols(V);
    V.fname = sprintf('tmpnorm%d.img',i);
    spm_write_vol(V,Y);
    V = spm_vol(V.fname);
    sap_normalize(V);
end;

V.fname = sprintf('ntmpnorm%d.img',1);
V = spm_vol(V.fname);
Y = spm_read_vols(V);
for i=2:length(fnames),
    V.fname = sprintf('ntmpnorm%d.img',i);
    V = spm_vol(V.fname);
    Yt = spm_read_vols(V);
    Y = Y + Yt;
end;
Y = Y/length(fnames);
if nargin<2,
    V.fname = sprintf('navg-%s-file.img',strtok(fnames{1},'-'));
else,
    V.fname = sprintf('navg-%s-file.img',str);
end;
spm_write_vol(V,Y);

if 0,
    fnames = {'kvs-0-sonata-20010111-170207-2-mri.mnc'; ...
            'kvs-0-sonata-20010111-170207-3-mri.mnc'; ...
            'kvs2-0-sonata-20010118-172144-2-mri.mnc'; ...
            'kvs2-0-sonata-20010118-172144-3-mri.mnc'};
    fnames = {'lm-0-sonata-20001018-153207-2-mri.mnc'; ...
            'lm-0-sonata-20001101-133018-2-mri.mnc'};
    fnames = {'jt-0-sonata-20001004-135417-2-mri.mnc'; ...
            'jt-0-sonata-20001004-135417-5-mri.mnc'};
    fnames = {'jw3-0-sonata-20010208-173441-2-mri.mnc'; ...
            'jw3-0-sonata-20010208-173441-8-mri.mnc'; ...
            'jw-0-sonata-20010215-171937-2-mri.mnc'; ...
            'jw-0-sonata-20010215-171937-3-mri.mnc'};
    fnames = {'jf-0-sonata-20010222-172851-2-mri.mnc'; ...
            'jf-0-sonata-20010222-172851-3-mri.mnc'; ...
            'jf-0-sonata-20010301-172450-3-mri.mnc'; ...
            'jf-0-sonata-20010301-172450-5-mri.mnc'};
    fnames = {'ms-0-sonata-20010308-172217-2-mri.mnc'; ...
            'ms-0-sonata-20010315-172417-2-mri.mnc'; ...
            'ms-0-sonata-20010308-172217-3-mri.mnc'; ...
            'ms-0-sonata-20010315-172417-3-mri.mnc'};  
    fnames = {'1772_2.img';'1772_3.img';'1822_2.img';'1822_3.img'};
    fnames = {'2041_2.img';'2041_3.img';'2096_2.img';'2096_3.img'};
    fnames = {'jb-0-allegra-20006-20010529-162243-3-mri.mnc';'127_4.img'};
    fnames = {'1879_2.img';'1879_3.img';'1928_2.img';'1928_3.img'};
end;
