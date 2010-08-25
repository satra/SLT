function demowait03
% DEMOWAIT01 Function demonstrates uiwaitbar functionality when it is
%   embedded in another figure or axes

fig = figure;
axh = subplot(15,3,3);
hproc = uiwaitbar(fig,axh,'Calculating histograms');
N = 1000;
for i=1:N,
    h = hist(rand(10000,1),linspace(0,1,100));
    uiwaitbar(i/N,hproc);
end;
delete(hproc);