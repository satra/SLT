function regions = sap_expert1(nodevalid)
%  SAP_EXPERT1 Auto generated file
% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/routines.1/sap_expert1.m 3     10/08/02 2:37p Satra $

% $NoKeywords: $

% PU labels
None=3;Gray=1;White=2;FP=68;iFt=13;FO=15;iFo=12;
adPMC=58;aSMA=55;TP=52;aINS=19;pINS=20;PP=33;H=18;
PT=35;aSTg=41;adSTs=62;avSTs=63;aMTg=42;pSTg=44;pdSTs=64;
pvSTs=65;pMTg=45;aCO=9;vPMC=61;mdPMC=59;pdPMC=60;pSMA=21;
vMC=56;dMC=57;dMC=69;pCO=67;vSSC=66;aSMg=38;PO=31;
pSMg=39;


% Node labels
CoronalSeries_FP=118;CoronalSeries_PlaneA=101;CoronalSeries_PlaneI=102;
CoronalSeries_Ins_Ant=103;CoronalSeries_Temp=104;CoronalSeries_CC_Genu=119;
CoronalSeries_Septum=105;CoronalSeries_BASFB=106;CoronalSeries_PlaneB=107;
CoronalSeries_PlaneJ=108;CoronalSeries_PlaneC=109;CoronalSeries_PlaneM=110;
CoronalSeries_Frt_Pos=111;CoronalSeries_He_Pos=112;CoronalSeries_PlaneD=113;
CoronalSeries_PlaneN=114;CoronalSeries_Splenium=115;CoronalSeries_PlaneF=116;
CoronalSeries_PlaneG=117;AxialSeries_SF_Prc=201;AxialSeries_PlaneK=202;
AxialSeries_PlaneL=203;AxialSeries_Poc_Hm=204;AxialSeries_Poc_Inpar=205;
AxialSeries_IJ_Inpar=206;LateralSagittalSeries_Ahr_Syl=302;LateralSagittalSeries_Aar_Syl=303;
LateralSagittalSeries_Aar_IF=304;LateralSagittalSeries_IF_Prc=305;LateralSagittalSeries_PlaneO=306;
LateralSagittalSeries_Ce_Syl=307;LateralSagittalSeries_PlaneP=308;LateralSagittalSeries_PlaneE=309;
MedialSaggitalSeries_PlaneH=401;MedialSaggitalSeries_Ci_Ant=402;MedialSaggitalSeries_Sp_Ci=403;
MedialSaggitalSeries_Sp_Calc=404;MedialSaggitalSeries_CunPnt=405;MedialSaggitalSeries_Cun_PO=406;
MedialSaggitalSeries_PO_Hm=407;

%CoronalSeries_PlaneF
Node{CoronalSeries_PlaneF}.Start = [];
Node{CoronalSeries_PlaneF}.Stop = [];

%CoronalSeries_FP
Node{CoronalSeries_FP}.Start = [FP];
Node{CoronalSeries_FP}.Stop = [];

%CoronalSeries_PlaneA
Node{CoronalSeries_PlaneA}.Start = [iFt];
Node{CoronalSeries_PlaneA}.Stop = [FP];

%CoronalSeries_PlaneI
Node{CoronalSeries_PlaneI}.Start = [];
Node{CoronalSeries_PlaneI}.Stop = [];

%CoronalSeries_Ins_Ant
Node{CoronalSeries_Ins_Ant}.Start = [aINS,pINS,FO];
Node{CoronalSeries_Ins_Ant}.Stop = [];

%CoronalSeries_PlaneG
Node{CoronalSeries_PlaneG}.Start = [];
Node{CoronalSeries_PlaneG}.Stop = [];

%CoronalSeries_Temp
Node{CoronalSeries_Temp}.Start = [];
Node{CoronalSeries_Temp}.Stop = [];

%CoronalSeries_CC_Genu
Node{CoronalSeries_CC_Genu}.Start = [adPMC,aSMA];
Node{CoronalSeries_CC_Genu}.Stop = [];

%CoronalSeries_Septum
Node{CoronalSeries_Septum}.Start = [];
Node{CoronalSeries_Septum}.Stop = [];

%CoronalSeries_BASFB
Node{CoronalSeries_BASFB}.Start = [];
Node{CoronalSeries_BASFB}.Stop = [];

%CoronalSeries_PlaneB
Node{CoronalSeries_PlaneB}.Start = [aSTg,adSTs,avSTs,aMTg,PP];
Node{CoronalSeries_PlaneB}.Stop = [];

%CoronalSeries_PlaneJ
Node{CoronalSeries_PlaneJ}.Start = [mdPMC,pSMA];
Node{CoronalSeries_PlaneJ}.Stop = [adPMC,aSMA];

%CoronalSeries_PlaneC
Node{CoronalSeries_PlaneC}.Start = [H,PT,pSTg,pdSTs,pvSTs,pMTg];
Node{CoronalSeries_PlaneC}.Stop = [aSTg,adSTs,avSTs,aMTg];

%CoronalSeries_PlaneM
Node{CoronalSeries_PlaneM}.Start = [];
Node{CoronalSeries_PlaneM}.Stop = [];

%CoronalSeries_Frt_Pos
Node{CoronalSeries_Frt_Pos}.Start = [];
Node{CoronalSeries_Frt_Pos}.Stop = [PP];

%CoronalSeries_He_Pos
Node{CoronalSeries_He_Pos}.Start = [];
Node{CoronalSeries_He_Pos}.Stop = [H,aINS,pINS];

%CoronalSeries_PlaneD
Node{CoronalSeries_PlaneD}.Start = [pSMg];
Node{CoronalSeries_PlaneD}.Stop = [aSMg,PO,PT,pSTg,pdSTs,pvSTs,pMTg];

%CoronalSeries_PlaneN
Node{CoronalSeries_PlaneN}.Start = [];
Node{CoronalSeries_PlaneN}.Stop = [];

%CoronalSeries_Splenium
Node{CoronalSeries_Splenium}.Start = [];
Node{CoronalSeries_Splenium}.Stop = [];

%AxialSeries_SF_Prc
Node{AxialSeries_SF_Prc}.Start = [];
Node{AxialSeries_SF_Prc}.Stop = [];

%AxialSeries_PlaneK
Node{AxialSeries_PlaneK}.Start = [];
Node{AxialSeries_PlaneK}.Stop = [pSMA,mdPMC];

%AxialSeries_PlaneL
Node{AxialSeries_PlaneL}.Start = [];
Node{AxialSeries_PlaneL}.Stop = [pdPMC,dMC];

%AxialSeries_Poc_Hm
Node{AxialSeries_Poc_Hm}.Start = [];
Node{AxialSeries_Poc_Hm}.Stop = [];

%AxialSeries_Poc_Inpar
Node{AxialSeries_Poc_Inpar}.Start = [];
Node{AxialSeries_Poc_Inpar}.Stop = [vSSC];

%AxialSeries_IJ_Inpar
Node{AxialSeries_IJ_Inpar}.Start = [];
Node{AxialSeries_IJ_Inpar}.Stop = [pSMg];

%LateralSagittalSeries_Ahr_Syl
Node{LateralSagittalSeries_Ahr_Syl}.Start = [];
Node{LateralSagittalSeries_Ahr_Syl}.Stop = [];

%LateralSagittalSeries_Aar_Syl
Node{LateralSagittalSeries_Aar_Syl}.Start = [iFo];
Node{LateralSagittalSeries_Aar_Syl}.Stop = [iFt];

%LateralSagittalSeries_Aar_IF
Node{LateralSagittalSeries_Aar_IF}.Start = [iFo];
Node{LateralSagittalSeries_Aar_IF}.Stop = [];

%LateralSagittalSeries_IF_Prc
Node{LateralSagittalSeries_IF_Prc}.Start = [pdPMC,dMC];
Node{LateralSagittalSeries_IF_Prc}.Stop = [iFo];

%LateralSagittalSeries_PlaneO
Node{LateralSagittalSeries_PlaneO}.Start = [aCO,vPMC,vMC];
Node{LateralSagittalSeries_PlaneO}.Stop = [FO];

%LateralSagittalSeries_Ce_Syl
Node{LateralSagittalSeries_Ce_Syl}.Start = [vSSC,pCO];
Node{LateralSagittalSeries_Ce_Syl}.Stop = [aCO];

%LateralSagittalSeries_PlaneP
Node{LateralSagittalSeries_PlaneP}.Start = [aSMg,PO];
Node{LateralSagittalSeries_PlaneP}.Stop = [pCO];

%LateralSagittalSeries_PlaneE
Node{LateralSagittalSeries_PlaneE}.Start = [];
Node{LateralSagittalSeries_PlaneE}.Stop = [pSTg];

%MedialSaggitalSeries_PlaneH
Node{MedialSaggitalSeries_PlaneH}.Start = [];
Node{MedialSaggitalSeries_PlaneH}.Stop = [];

%MedialSaggitalSeries_Ci_Ant
Node{MedialSaggitalSeries_Ci_Ant}.Start = [];
Node{MedialSaggitalSeries_Ci_Ant}.Stop = [];

%MedialSaggitalSeries_Sp_Ci
Node{MedialSaggitalSeries_Sp_Ci}.Start = [];
Node{MedialSaggitalSeries_Sp_Ci}.Stop = [];

%MedialSaggitalSeries_Sp_Calc
Node{MedialSaggitalSeries_Sp_Calc}.Start = [];
Node{MedialSaggitalSeries_Sp_Calc}.Stop = [];

%MedialSaggitalSeries_CunPnt
Node{MedialSaggitalSeries_CunPnt}.Start = [];
Node{MedialSaggitalSeries_CunPnt}.Stop = [];

%MedialSaggitalSeries_Cun_PO
Node{MedialSaggitalSeries_Cun_PO}.Start = [];
Node{MedialSaggitalSeries_Cun_PO}.Stop = [];

%MedialSaggitalSeries_PO_Hm
Node{MedialSaggitalSeries_PO_Hm}.Start = [];
Node{MedialSaggitalSeries_PO_Hm}.Stop = [];

regions = [];
nodevalid = nodevalid(:)';
for i=nodevalid,
   regions = union(regions,Node{i}.Start);
end;
for i=nodevalid,
   regions = setdiff(regions,Node{i}.Stop);
end;


