function regions = sap_expert(nodevalid)
% SAP_EXPERT Determine the regions in the current slice
%   Based on the nodes inthe volume and the position of the current slice 
%   relative to the nodes, the following utility determines all the PUs on
%   the current slice.
%   This version does not take into account anything other than the coronal 
%   dimension. Future versions of this will actually list a probabilistic
%   order of nodes for any given voxel in the image.
%   The only input is the set of nodes anterior to the current slice.
%   n1 n2 n3 n4 n5 n6
%        ^
%       slice
%   Then nodevalid = [1 2]
%   The output is a list of possible PUs on the slice.

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/routines.1/sap_expert.m 2     10/08/02 2:37p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

AG=1; CALC=2; CGa=3; CGp=4; CN=5; CO=6; 
F1=7; F2=8; F3o=9; F3t=10; FMC=11; FO=12; 
FOC=13; FP=14; H=15;aINS=16;pINS=17;JPL=18;LG=19; 
OF=20; OLi=21; OLs=22; OP=23; PAC=24; 
PCN=25; PHa=26; PHp=27; PO=28; POG=29; 
PP=30; PRG=31; PT=32; SC=33; SCLC=34; 
SGa=35; SGp=36; SPL=37; T1a=38; T2a=39;
T3a=40; T1p=41; T2p=42; T3p=43; TFa=44; 
TFp=45; TO2=46; TO3=47; TOF=48; TP=49;
CGpc=50; BASFB=51;

% FR
Node{1}.Start = [FP];
Node{1}.Stop = [];

% Plane H
Node{2}.Start = [F1 PAC FMC];
Node{2}.Stop = [];

% Plane A
Node{3}.Start = [F2 F3t FOC];
Node{3}.Stop = [FP];

% Ci-Ant
Node{4}.Start = [CGa];
Node{4}.Stop = [];

% Plane-I
Node{5}.Start = [SC];
Node{5}.Stop = [FMC];

% Ins-Ant
Node{6}.Start = [aINS FO];
Node{6}.Stop = [SC];

% Plane T
Node{7}.Start = [TP];
Node{7}.Stop = [];

% Septum
Node{8}.Start = [BASFB];
Node{8}.Stop = [SC];

% BASFB
Node{9}.Start = [];
Node{9}.Stop = [FOC];

% Plane B
Node{10}.Start = [T1a T2a T3a TFa PHa PP];
Node{10}.Stop = [TP];

% Aar-Inf
Node{11}.Start = [F3o];
Node{11}.Stop = [];

% Ahr-Syl
Node{12}.Start = [];
Node{12}.Stop = [F3t];

% Aar-Syl
Node{13}.Start = [];
Node{13}.Stop = [];

% Plane O
Node{14}.Start = [CO PRG];
Node{14}.Stop = [FO];

% IF-Prc
Node{15}.Start = [];
Node{15}.Stop = [F3o];

% Ce-Syl
Node{16}.Start = [POG];
Node{16}.Stop = [];

% SF-Prc
Node{17}.Start = [];
Node{17}.Stop = [F2];

% Plane J
Node{18}.Start = [JPL];
Node{18}.Stop = [PAC];

% Plane C
Node{19}.Start = [T1p T2p T3p TFp H PT];
Node{19}.Stop = [T1a T2a T3a TFa];

% Plane P
Node{20}.Start = [SGa PO];
Node{20}.Stop = [CO];

% Plane M
Node{21}.Start = [PHp];
Node{21}.Stop = [PHa];

% Plane K
Node{22}.Start = [CGp];
Node{22}.Stop = [F1 CGa JPL];

% Frt-Pos
Node{23}.Start = [];
Node{23}.Stop = [PP];

% He-Pos
Node{24}.Start = [];
Node{24}.Stop = [H aINS];

% Plane L
Node{25}.Start = [];
Node{25}.Stop = [PRG];

% Poc-IP
Node{26}.Start = [SPL];
Node{26}.Stop = [];

% Sp-Ci
Node{27}.Start = [PCN];
Node{27}.Stop = [];

% Plane D
Node{28}.Start = [SGp TO2 TO3 TOF];
Node{28}.Stop = [SGa PO T1p T2p T3p TFp PT];

% Plane N
Node{29}.Start = [LG CGpc];
Node{29}.Stop = [];

% Poc-Hm
Node{30}.Start = [];
Node{30}.Stop = [POG];

% Plane E
Node{31}.Start = [AG];
Node{31}.Stop = [];

% IJ-IP
Node{32}.Start = [];
Node{32}.Stop = [SGp];

% Sp-Calc
Node{33}.Start = [];
Node{33}.Stop = [CGp];

% Plane F
Node{34}.Start = [OLs OLi OF];
Node{34}.Stop = [TO2 TO3 TOF AG SPL];

% CunPnt
Node{35}.Start = [CALC SCLC];
Node{35}.Stop = [];

% Cun-PO
Node{36}.Start = [CN];
Node{36}.Stop = [];

% PO-Hm
Node{37}.Start = [];
Node{37}.Stop = [PCN];

% Plane G
Node{38}.Start = [OP];
Node{38}.Stop = [LG OLs OLi OF CALC SCLC CN];

% OC
Node{39}.Start = [];
Node{39}.Stop = [OP];

% Splenium
Node{40}.Start = [];
Node{40}.Stop  = [];

% Coll-Pos
Node{41}.Start = [];
Node{41}.Stop  = [];

regions = [];
for i=nodevalid,
   regions = union(regions,Node{i}.Start);
end;
for i=nodevalid,
   regions = setdiff(regions,Node{i}.Stop);
end;