function [Mask, Labels]=OTL2Mask(OTL,SizeM);
% OTL2MASK Creates Mask from OTL info
%
% Mask=OTL2Mask(OTL [,SizeMask])
%		OTL	: 	as in OTLREAD...
%		Mask	:	indexed image
%

CONTOURVALUE=0;
Labels{1}='';
if nargin<2 | isempty(SizeM), SizeM=OTL(1).Size; end
SizeM=SizeM(:)';
Mask=zeros([SizeM, length(OTL)]);
OnesM=ones(SizeM);
Trans=SizeM./OTL(1).Size;
for n1=1:length(OTL),
   for idxOTL=1:length(OTL(n1).Label),
      idxMask=strmatch(OTL(n1).Label{idxOTL},Labels,'exact');
      if isempty(idxMask),
         idxMask=length(Labels)+1;
         Labels{idxMask}=OTL(n1).Label{idxOTL};
      end
      for idxPart=1:OTL(n1).Parts(idxOTL),
         Mask(:,:,n1)=Mask(:,:,n1) + idxMask*double(...
            roipoly(OnesM,...
            round(Trans(2)*(OTL(n1).Region(idxOTL).Contour{idxPart}(:,1)-1)),...
            round(Trans(1)*(OTL(n1).Region(idxOTL).Contour{idxPart}(:,2)-1)))...
            );
         Mask(prod(SizeM)*(n1-1)+...
            SizeM(1)*(round(Trans(2)*(OTL(n1).Region(idxOTL).Contour{idxPart}(:,1)-1)))+...
            round(Trans(1)*OTL(n1).Region(idxOTL).Contour{idxPart}(:,2))) = ...
            CONTOURVALUE;   
         %            length(OTL.Label)+1;
      end
   end
end

