function plotTFR1(sig,tfr,pos)

figure('Doublebuffer','on','menu','none');

pos1 = [0.01 0.2 0.98 0.78];
pos2 = [0.01 0.01 0.98 0.17];

a(1) = axes('units','normalized','position',pos1);
image(tfr);axis off;axis xy;

a(2) = axes('units','normalized','position',pos2);
plot(sig);axis tight;
