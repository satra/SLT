function M=GDF2M(FileName,M,idx);

% GDF2M Reads .gdf file
% M=GDFread(FileName,M)
%		Filename	:	gdf file to be read
%		M			:	Original M matrix
%		idx		:	Original reindexing
% 	returns corrected M (affine transformation matrix)
%


fid=fopen(FileName,'r','ieee-be');
stop=0; idxOTL1=1; Prec_0='short';
OTL.Label{1}='';
OTL.Parts(1)=0;
while ~stop,
   str=fgetl(fid);
   if ~isstr(str), stop=1;
   elseif ~isempty(str),
      [str_1, str_2]=strtok(str);
      %         disp([str_1, ' ---- ', str_2]);
      switch upper(str_1),
      case 'DISPLAY_CENTER', Center=str2num(str_2);
      case 'NORMALIZATION_ORIGIN', Origin=str2num(str_2);
      case 'NORMALIZATION_ANGLES', Rot=str2num(str_2);
      case 'SIZE', S_im=str2num(str_2);
      case 'SL_THICK', Res_sl=str2num(str_2);
      case 'IP_RES', Res_im=str2num(str_2);
      end
   end
end
fclose(fid);
S_sl=2*Orig0(2)-3; % (# of slices...)

% Get rotation matrix
Rx=[1,0,0; 0,cos(Rot(2)),-sin(Rot(2));0,sin(Rot(2)),cos(Rot(2))];
Ry=[cos(Rot(3)),0,-sin(Rot(3));0,1,0;sin(Rot(3)),0,cos(Rot(3))];
Rz=[cos(Rot(1)),-sin(Rot(1)),0;sin(Rot(1)),cos(Rot(1)),0;0,0,1];
R=inv(Rx*Ry*Rz);
R=R(:,idx);
x0=Origin-R*Center;
M0=[R,x0;zeros(1,3),1];
M=M*M0;


S=[S_sl, S_im];
Res=[Res_sl, Res_im];
% Coronal orientation %%%%%%%%%%%%%%%
Dir00=[ 0, 1, 0;
   1, 0, 0;
   0, 0, 1];
Dir0=Dir00*diag(Res);
%Orig=[Res_im(1),Res_sl,Res_im(2)].*(Orig00-Orig0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Creates Grid
Rx=[1,0,0; 0,cos(Rot(2)),-sin(Rot(2));0,sin(Rot(2)),cos(Rot(2))];
Ry=[cos(Rot(3)),0,-sin(Rot(3));0,1,0;sin(Rot(3)),0,cos(Rot(3))];
Rz=[cos(Rot(1)),-sin(Rot(1)),0;sin(Rot(1)),cos(Rot(1)),0;0,0,1];
Orig=-[Res_im(1);Res_sl;Res_im(2)].*...
	[0;-1.25;2]; %[0;-1.25;4]; % Y Z X
%	[-4;-3;17]; % X Z Y
%	[-2.75; 1.18; 0.75]; % Y Z X
%	[-3.75;0.73;5]; % Y Z X
%	[-5.25;1.45;-2]; % Y Z X
%	[-4.5;1.28;-5]; % Y Z X
%	[0.5;-2.1;4.75]; % Y Z X
%	[-3;0.5;-18.8]; % Y Z X
%	[-6.75;-2.19;-17]; % Y Z X
%	[1;2.91;5]; % Y Z X
%	[;;]; % Y Z X
Dir0=Rz*Ry*Rx*Dir0*diag(S);
Grid=Ax2Grid(Orig, Dir0, S);
