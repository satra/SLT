%function calcplotTFR

m = morlet_bases2(1:0.5:40,1000,5);
hproc = uiwaitbar('Calculating TFR');
TFR = zeros(length(m),length(mV),93);
for i=1:93,
    TFR(:,:,i) = traces2TFR3(mV(i,:)',m,1000);
    uiwaitbar(i/93,hproc);
end;
delete(hproc);

plotTFRKIT(512*TFR/max(TFR(:)));