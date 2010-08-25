function [imainfo,data,m] = sap_readseries(plane)
%clear all;close all;

%h = pst_imagui;
%set(findtag('ima_uifile'),'Callback','ima_getfile;');
%uiwait(h);

%imainfo = get(findtag('pst_imafig'),'userdata');
%imainfo.template = get(findtag('ima_template'),'String');
%imainfo.range = str2num(get(findtag('ima_range'),'String'));
%close(h);

%m = ima_headread([imainfo.path imainfo.fname]);

[imainfo,m] = ima_getfile;

m.h_G18_Acq_SliceThickness
m.h_G21_Rel1_CM_FoV_Height = 256;
m.h_G21_Rel1_CM_FoV_Width = 256;
m.h_G20_Rel_Image
m.h_G21_Rel1_CM_ImageNormal_Sag
m.h_G21_Rel1_CM_ImageNormal_Cor
m.h_G21_Rel1_CM_ImageNormal_Tra
m.h_G28_Pre_PixelSize_Row
m.h_G28_Pre_PixelSize_Column
m.h_G51_Txt_Matrix

if nargin==1,
    imainfo.plane = plane;
end;
    
n = length(imainfo.range(1):imainfo.range(2));
switch(imainfo.plane),
case 1,
   data = zeros(n,m.h_G21_Rel1_CM_FoV_Width,m.h_G21_Rel1_CM_FoV_Height);
case 2,
   data = zeros(m.h_G21_Rel1_CM_FoV_Width,n,m.h_G21_Rel1_CM_FoV_Height);
case 3,
   data = zeros(m.h_G21_Rel1_CM_FoV_Width,m.h_G21_Rel1_CM_FoV_Height,n);
end;

datat = zeros(m.h_G21_Rel1_CM_FoV_Height,m.h_G21_Rel1_CM_FoV_Width);
%imshow(datat);
%set(gcf,'DoubleBuffer','on');
for i=imainfo.range(1):imainfo.range(2),
   fname = sprintf(imainfo.template,i);
   
   fid = fopen([imainfo.path fname],'rb');
   if fid < 0
      disp(['can''t open file	' fname]);
      return;
   end;
   fseek(fid,6144,'bof');
   datat = fread(fid,[m.h_G21_Rel1_CM_FoV_Height m.h_G21_Rel1_CM_FoV_Width],'uint16');
	%fprintf('[%d]',i);
   %imagesc(datat);drawnow;
   n = i-imainfo.range(1)+1;
   switch(imainfo.plane),
   case 1, %saggital
      data(n,:,:) = datat;
   case 2, %coronal
      data(:,n,:) = datat;
   case 3, %axial
      data(:,:,n) = datat;
   end;
   fclose(fid);
end;