function [Inters, Vals]=FindInters(Grid, Line, Operator);
% Inters=FindInters(Grid, Line, Operator);
%
% Finds Intersection points of a given Line along a Grid.
% Linealizes the Line for getting more precission at intersections.
%
%	Grid		:	[[G1.1; G1.2], [G2.1; G2.2], [G3.1; G3.2], ...]
%					Gi.j	-> x+i*y, i-th line of the grid
%	Line		:	[P1, P2, P3, ...]
%					Pi		-> x+i*y, i-th point of the Line
%	Operator	:	'min'		Handle multiple intersections (for a given grid line) case.
%					'max'
%


if nargin<3, Operator='min'; end

ZeroPos	=Grid(1,:);
LineDir	=ones(length(Line),1)*(Grid(2,:)-ZeroPos);
PerpDir	=ones(length(Line),1)*i*(Grid(2,:)-ZeroPos);
LineRel	=Line.'*ones(1,size(Grid,2)) - ones(length(Line),1)*ZeroPos;

% Projection of points in Line in direction perp. to Grid lines
ProjA=real(PerpDir).*real(LineRel)+imag(PerpDir).*imag(LineRel);	% (dot product)
% Projection of points in Line in direction of Grid lines
ProjB=real(LineDir).*real(LineRel)+imag(LineDir).*imag(LineRel);	% (dot product)

% Where the Line crosses the Grid... (in the right side of the Base)
CrA=xor(ProjA(1:end-1,:)>0, ProjA(2:end,:)>0) & (ProjB(1:end-1,:)>0);

% Selects among (possible) multiple intersections
switch(Operator)
case 'min',
   TempInf=2*max(max(abs(LineRel)));
   [null, idxPosA]=min(TempInf*(~CrA)+abs(LineRel(1:end-1,:)));
   idxValid=find(null<TempInf);
   idxnoValid=find(null>=TempInf);
case 'max',
   [null, idxPosA]=max(CrA.*abs(LineRel(1:end-1,:)));
   idxValid=find(null>0);
   idxnoValid=find(null<=0);
case 'all',
   TempInf=2*max(max(abs(LineRel)));
   [null, idxPosA]=sort(TempInf*(~CrA)+abs(LineRel(1:end-1,:)));
   idxValid=find(null<TempInf);
   idxnoValid=find(null>=TempInf);
end

% Finds indexes for last "+". and first "-" projections (and its proj. values)
IdxIntersNeg=ones(size(idxPosA)); IdxIntersPos=ones(size(idxPosA));
IdxIntersNeg(idxValid)=idxPosA(idxValid);
IdxIntersPos(idxValid)=idxPosA(idxValid)+1;
TempGrid=length(Line)*(0:size(Grid,2)-1); %to rearrange indexes
ValIntersNeg=abs(ProjA(IdxIntersNeg(:)+TempGrid(:)));
ValIntersPos=abs(ProjA(IdxIntersPos(:)+TempGrid(:)));

% Linear Intersection
Alpha=ValIntersPos./(ValIntersPos+ValIntersNeg);

Inters=Alpha.*Line(IdxIntersNeg).'+(1-Alpha).*Line(IdxIntersPos).';
Inters=reshape(Inters,size(idxPosA));
Vals=abs(Inters-ones(size(Inters,1),1)*ZeroPos)./(ones(size(Inters,1),1)*abs(Grid(2,:)-ZeroPos));

Inters(idxnoValid)=NaN;
Vals(idxnoValid)=NaN;
