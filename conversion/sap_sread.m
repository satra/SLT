function sap_sread(plane);

if nargin==1,
    [imainfo,data,m] = sap_readseries(plane);
else,
    [imainfo,data,m] = sap_readseries;
end;
imainfo
max(data(:))
%data = uint8(255*data/max(data(:)));
data = uint16(data);

switch imainfo.plane,
case 1,
    data1 = data;
case 2,
    data1 = permute(data,[2 1 3]);
case 3,
    data1 = permute(data,[3 2 1]);
end;

%data1 = sap_cleanplane(data1);

switch imainfo.plane,
case 1,
case 2,
    data1 = permute(data1,[2 1 3]);
case 3,
    data1 = permute(data1,[3 2 1]);
end;

%data = uint8(data1);
data = uint16(data1);
clear data1;

switch imainfo.plane,
case 1,
    data=data(:,end:-1:1,end:-1:1);
    V.mat = diag([m.h_G18_Acq_SliceThickness ...
            m.h_G28_Pre_PixelSize_Row ...
            m.h_G28_Pre_PixelSize_Column 1]);
case 2,
    data=data(:,:,end:-1:1);
    V.mat = diag([m.h_G28_Pre_PixelSize_Row ...
            m.h_G18_Acq_SliceThickness ...         
            m.h_G28_Pre_PixelSize_Column 1]);
case 3,
    V.mat = diag([m.h_G28_Pre_PixelSize_Row ...
            m.h_G28_Pre_PixelSize_Column ...
            m.h_G18_Acq_SliceThickness 1]);         
end;

disp('Writing analyze format file ...');
Y = data;
Y = Y(end:-1:1,:,:);
clear data;
size(Y)
V.fname = sprintf('%d_%d.img',imainfo.sbjno,imainfo.ser_no);
V.dim = [size(Y) 4];
V.pinfo = [0 0 0]';
V.descrip = '';
sth = diag(V.mat);
V.mat(1:3,4) = -1*sth(1:3).*[size(Y)/2]';
[V.fname]

spm_write_vol(V,Y);
%sap_normalize(V);