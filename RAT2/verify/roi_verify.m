function roi_verify(ROIfile,vol)

load(ROIfile,'-MAT');

load ~/software/SLT/scripts/satra/sp01code/runinfo_sp01.mat

Y = xY.y;
mY = (Y-repmat(mean(Y),size(Y,1),1));
                                      %%./repmat(std(Y),size(Y,1),1);

figure;
if vol==1,
    plot(mean(detrend(mY(1:2:end,:)),2),'.-');
else
    plot(mean(detrend(mY(2:2:end,:)),2),'.-');
end
hold on
plot(-1*(runinfo(:,1)==5)+0,'r.-')     
