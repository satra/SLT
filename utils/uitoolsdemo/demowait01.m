function demowait01
% DEMOWAIT01 Function demonstrates uiwaitbar functionality when it creates
%   its own figure

hproc = uiwaitbar('Calculating histograms');
N = 1000;
for i=1:N,
    h = hist(rand(10000,1),linspace(0,1,100));
    uiwaitbar(i/N,hproc);
end;

%delete(hproc)
% or reuse;
