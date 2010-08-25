%load jb_data_results_0539.mat ImageGridAmp;
%load surf_datboth.mat;

t = inf;
f1 = figure;
plot(ImageGridAmp(1:100:72144,:)');

f2 = figure;
offset = 101;


while (t~=-666)
    figure(f1);
    %t = input('Time point? ');
    [x,y] = ginput(1)
    t = floor(x);
    figure(f2);
    [az,el] = view;
    maxAmp = max(abs(ImageGridAmp(:,t+offset)));
%    showVertexValue(brain_schizo,(round(ImageGridAmp(:,t+offset) ./ maxAmp .* 64)));
    showVertexValue(brain_schizo,ImageGridAmp(:,t+offset)./maxAmp);
    view(az,el);
    axis tight;
    light;
    title(sprintf('t = %d ms',t));
    colorbar;
    figure(f1);
    title(sprintf('t = %d ms',t));
    input('Press enter to continue');
end;