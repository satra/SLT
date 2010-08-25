function [OTL,Mask,Labels]=OTLreadset(SetName,SizeMask);
% OTLREADSET Reads set of .otl files
% [OTL,Mask,Labels]=OTLreadset(SetName [,SizeMask]);

if nargin<2, SizeMask=[]; end

[SetPath,SetName]=fileparts(SetName);
D=dir(fullfile(SetPath,[SetName,'*.otl']));
for n1=1:length(D),
   [nill,str]=fileparts(D(n1).name);
   temp=find(str<'0' | str>'9');
   idx(n1)=( str2num(str(temp(end)+1:end)) -1 )/3 +1; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   disp(['Reading #', num2str(idx(n1))]);
   OTL(idx(n1))=OTLread(fullfile(SetPath,D(n1).name));
end
% sets empty slices
if length(SizeMask)<3, N=max(idx); else N=SizeMask(3); end
idxnull=setdiff(1:N,idx);
for n1=idxnull(:).', OTL(n1).Size=OTL(idx(1)).Size; end

% gets mask
if nargout>1,
   [Mask,Labels]=OTL2Mask(OTL, SizeMask(1:2));
end
