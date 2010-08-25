
load ms_data_results_2124 ImageGridAmp;
load('E:\00_PILOT\RAW\mriSurfaces.mat','cortex');

offset = 100;
times = [50 100 150 200 250 300 350 400];
colormap(hsv);
f = zeros(length(times),1);

figure;
for i=1:length(times),
%for i=1:1
    subplot(2,4,i);
    showVertexValue(cortex,round(ImageGridAmp(:,times(i)+offset)./max(max(ImageGridAmp))*64),1);
    view(-60,2);
    light('Position',[1 0 1],'Color','white');
    colorbar;
    title(sprintf('%d ms',times(i)));
end;