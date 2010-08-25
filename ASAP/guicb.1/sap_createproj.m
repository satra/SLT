function projfile = sap_createproj(imgfile)
% SAP_CREATEPROJ Creates an ASAP project silently

data.setflag = 1;
data.convert = 1;
data.init    = 0;

[pth,nm,xt] = fileparts(imgfile);

data.filename = [nm,xt];
data.pathname = pth;
data.projfile = [nm,'.spt'];
data.projpath = pth;
projfile = fullfile(data.projpath,data.projfile);

sap_prnew(data);