function msg = incheck(varargin)
%CHECKIN checks inputs

if nargin < 2; error('Incorrect number of input arguments'); end

if nargin ~= 2; 
   error('Incorrect number of input arguments');
elseif nargin == 2
   [lat,lon]= deal(varargin{:});
end


msg = [];

if ~isa(lat,'numeric') | ~isa(lon,'numeric')
   
   msg = 'x and y must be numeric vectors';
   
elseif any([min(size(lat))    min(size(lon))]    ~= 1) | ...
      any([ndims(lat) ndims(lon)] > 2)
   
   msg = 'x and y inputs must be vectors';
   
elseif ~isequal(size(lat),size(lon))
   
   msg = 'Inconsistent dimensions on x and y input';
   
elseif ~isequal(find(isnan(lat)),find(isnan(lon)))
   
   msg = 'Inconsistent NaN locations in x and y input';
   
end


