function [cdataRGB, mincdata, maxcdata] = index2RGB(cdata)
% Map indices to RGB triples with a provision for NaNs and Infs. 
% [cdataRGB, mincdata, maxcdata] = index2RGB(cdata)
%
% Takes the values in cdata (which should be a vector of reals)
% and maps them into the colormap of the current figure, or into
% jet(64) if no figures are open. 

V = size(cdata, 1);
if size(cdata, 2) ~= 1
  fprintf('%s should be a vector\n', inputname(1));
  error('Exiting ...');
end

if isempty(get(0, 'Children'))
  cmap = jet(64);
else
  cmap = colormap;
end
  
cc = size(cmap,1) - 1;
index = find( ~isnan(cdata) & ~isinf(cdata) );
mincdata = min(cdata(index));
maxcdata = max(cdata(index));

if maxcdata - mincdata > sqrt(eps)
  cmapindices = 1 + round(cc*(cdata(index)-mincdata)/ ...
			  (maxcdata-mincdata) );
else
  cmapindices = repmat( round(cc/2), size(index) );
end

cdataRGB = repmat(0.5, V, 3);
cdataRGB(index, :) = cmap( cmapindices, : );
