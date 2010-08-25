function [M,idx,sM,data]=siemens_header2M(hdr,data,Nnormal);
if nargin<3, Nnormal=1; end
if nargin<2, data=[]; end

D=eye(3);
t=[hdr.h_G21_Rel1_CM_ImageRow_Sag;
   hdr.h_G21_Rel1_CM_ImageRow_Cor;
   -hdr.h_G21_Rel1_CM_ImageRow_Tra];
Nrow=hdr.h_G28_Pre_Rows;
Row=sum(D*t,2)*Nrow*hdr.h_G28_Pre_PixelSize_Row;
t=[hdr.h_G21_Rel1_CM_ImageColumn_Sag;
   hdr.h_G21_Rel1_CM_ImageColumn_Cor;
   -hdr.h_G21_Rel1_CM_ImageColumn_Tra];
Ncolumn=hdr.h_G28_Pre_Columns;
Column=sum(D*t,2)*Ncolumn*hdr.h_G28_Pre_PixelSize_Column;
t=[hdr.h_G21_Rel1_CM_ImageNormal_Sag;
   hdr.h_G21_Rel1_CM_ImageNormal_Cor;
   -hdr.h_G21_Rel1_CM_ImageNormal_Tra];
%Nnormal=hdr.h_G28_Pre_ImageDimension;
Normal=sum(D*t,2)*Nnormal*hdr.h_G18_Acq_SliceThickness;
t=[hdr.h_G21_Rel1_CM_ImagePosition_Sag;
   hdr.h_G21_Rel1_CM_ImagePosition_Cor;
   -hdr.h_G21_Rel1_CM_ImagePosition_Tra];
%Position=sum(D*t,2);

Nim1=hdr.h_G28_Pre_Rows/hdr.h_G19_Acq3_Mr_BaseRawMatrixSize;
Nim2=hdr.h_G28_Pre_Columns/hdr.h_G19_Acq3_Mr_BaseRawMatrixSize;

Normal=Normal*Nim1*Nim2;
Nnormal=Nnormal*Nim1*Nim2;
Position=-.5*(Column+Row+Normal);


if Nim1~=1 | Nim2~=1,
   sM=[Nrow/Nim1, Nim1, Ncolumn/Nim2, Nim2, Nnormal/Nim1/Nim2];
   [M,idx]=box2m(Position,Position+Column,Position+Row+Column,Position+Normal,Position+Normal+Column,Position+Normal+Row+Column,Nrow/Nim1,Ncolumn/Nim2,Nnormal);
   idx0=[1 3 5]; idx=[idx0(idx), 2, 4];
else   
	sM=[Nrow,Ncolumn,Nnormal];
	[M,idx]=box2m(Position,Position+Column,Position+Row+Column,Position+Normal,Position+Normal+Column,Position+Normal+Row+Column,Nrow,Ncolumn,Nnormal);
end


if nargout>3 & ~isempty(data),
   data=permute(reshape(data,sM),idx);
   if length(idx)>3,
      idx0=find(sM(idx(1:3))==1);
      idx1=1:4; idx1(idx0)=4; idx1(4)=idx0;
      data=permute(data(:,:,:,:),idx1);
   end
end

