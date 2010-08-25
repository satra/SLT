function [data,otl,offset] = sap_convert(srcdata,handles);
tic;
[fname,srcdir] = strtok(fliplr(srcdata),filesep);
fname = fliplr(fname);
srcdir=fliplr(srcdir);
pdir = pwd;
cd(srcdir);
V = spm_vol(fname);
if 0,
    if ~exist(['m' V.fname],'file'),
        Y = spm_read_vols(V);
        hproc = waitbar(0,'Median Filtering','units','normalized','Position',[0.1 0.1 0.35 0.1]);
        for i=1:size(Y,1);
            Y(i,:,:) = medfilt2(squeeze(Y(i,:,:)));
            waitbar(i/size(Y,1),hproc);
        end;
        close(hproc);
        V.fname = ['m' V.fname];
        spm_write_vol(V,Y);
        clear Y;
    else,
        V.fname = ['m' V.fname];    
    end;
end;
V = spm_vol(V.fname);
% if ~exist(['n' V.fname],'file'),
%     sap_status(handles,'Normalizing ...');
%     sap_normalize(V);
% end;
sap_status(handles,'Segmenting ...');
H = sap_preprocess([V.fname]);
sap_status(handles,'Extracting ...');
[data,otl,offset] = sap_preprocess2(H);
data = double(data);
cd(pdir);
toc;
