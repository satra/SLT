function y = squeezeu8(varargin)
%ISNAN Overloaded function for UINT8 input.

%   $Revision: 2 $  $Date: 10/08/02 2:37p $
%   Copyright (c) 1984-98 by The MathWorks, Inc.

for k = 1:length(varargin)
  if (isa(varargin{k},'uint8')) | (isa(varargin{k},'uint16'))
    varargin{k} = double(varargin{k});
  end
end

y = squeeze(varargin{:});

