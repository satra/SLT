function demowait02
% DEMOWAIT01 Function demonstrates uiwaitbar functionality when it is
%   embedded in another figure or axes

fig = figure;
pos = [0.6 0.8 0.35 0.05];
hproc = uiwaitbar(fig,pos,'Calculating histograms');
N = 1000;
for i=1:N,
    h = hist(rand(10000,1),linspace(0,1,100));
    uiwaitbar(i/N,hproc);
end;
delete(hproc);