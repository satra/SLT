time = [1:450];

roi = [28714];
labels = {'right Face Area'};

for i=1:length(roi),
    figure;
    n = neighbors(sBrain,roi(i));
    m = mean(ImageGridAmp([roi(i); n],:),1);
    s = std(ImageGridAmp([roi(i); n],:),1);
    plot(time,m+s,'b',time,m-s,'b',time,zeros(length(time)),'r');
    xlabel('Time after onset (ms)');
    ylabel('Amplitude');
    title(sprintf('%s (i:%d)',labels{i},roi(i)));
end;