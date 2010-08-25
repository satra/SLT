function Out=loadfile(varargin);
% LOADFILE
% Like LOAD, but returns output arguments
% (just like in windows environment, in
% case it is not implemented -as in unix...)
%

load(varargin{:});
clear varargin;
Vars=who;

Out=[];
for n1=1:length(Vars);
   Out=setfield(Out, Vars{n1}, eval(Vars{n1}));
end

