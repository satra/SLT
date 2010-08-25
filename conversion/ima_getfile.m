function [imainfo,m] = ima_getfile;

[a,b] = uigetfile('*.ima');
if (a==0),
   imainfo = [];
   return;
end;

imainfo.path = b;
imainfo.fname = a;

%set(findtag('ima_fname'),'String',imainfo.fname);

[t,r] = strtok(imainfo.fname,'-');
r = r(2:end);
r = strtok(r,'-');
imainfo.ser_no = str2num(r);

imainfo.sbjno = str2num(t);
locn = length(t)+1+length(r);

imainfo.template = sprintf('%d-%d-%%d.ima',imainfo.sbjno,imainfo.ser_no);

ct = 0;
D = dir([imainfo.path filesep sprintf('%d-%d-*.ima',imainfo.sbjno,imainfo.ser_no)]);
size(D)
for i=1:length(D),
   str = D(i).name;
   [t,r] = strtok(D(i).name,'.');
   ct = ct+1;
   imgno(ct) = str2num(t(locn+2:end));
end;
rng = [min(imgno) max(imgno)];
imainfo.range = rng;

%set(findtag('ima_template'),'String',imainfo.template);
%set(findtag('ima_range'),'String',sprintf('[%d %d]',rng(1),rng(2)))

m = ima_headread([imainfo.path imainfo.fname]);

if (m.h_G21_Rel1_CM_ImageNormal_Sag == 1),
   imainfo.plane = 1;
elseif m.h_G21_Rel1_CM_ImageNormal_Cor == 1,
   imainfo.plane = 2;
elseif m.h_G21_Rel1_CM_ImageNormal_Tra == 1,
   imainfo.plane = 3;
else,
   imainfo.plane = -1;
end;

imainfo.size = [m.h_G21_Rel1_CM_FoV_Height m.h_G21_Rel1_CM_FoV_Width];
imainfo.thick= m.h_G18_Acq_SliceThickness;
imainfo.num = m.h_G20_Rel_Image;

str = sprintf('%d:P[%d]S[%dx%d]T[%1.2f]',imainfo.num,...
   imainfo.plane,imainfo.size(1),imainfo.size(2),imainfo.thick);

%set(findtag('ima_dim'),'String',str);

%set(findtag('pst_imafig'),'userdata',imainfo);
