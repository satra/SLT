 
vertices = [30046,39893,39863,14246,57753,40079,26407,57842];
% 21305,32426, 'left Visual Area 1','left Visual Area 2',
labels = {'left Temporal Occipital',...
          'left Extreme pSTG','left STG','left Fusiform Area',...
          'left Premotor Area','right Extreme pSTG','right Temporal Occipital',...
          'right Premotor Area'};
  
  
figure;
for i=1:8,
    subplot(2,4,i);
    nb = [vertices(i); neighbors(sBrain,vertices(i));];
    plot((ImageGridAmp(nb,:).*10^12)','k'); hold on; plot(mean((ImageGridAmp(nb,:).*10^12)',2),'r','LineWidth',2);
    title(sprintf('%s (v:%d)',labels{i},vertices(i)));
    axis tight;
end;