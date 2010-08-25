%graymap_make
% creates an nx3 matrix that can be used as
% a colormap 
close all;
% grayscale map with nonlinear transition from positive to negative 
% direction of activation
n=89;
bvec=([1:n]./(n*2))';%gray to black
bvec=bvec(26:n);
gmap=[bvec bvec bvec];
wvec=gmap+.5;
gmap=[gmap;wvec];
gmap=[gmap(1:64,:);[.5 .5 .5];gmap(65:end,:)];
nonlinear_gmap=gmap;
colormap(nonlinear_gmap);colorbar;

save('nonlinear_gmap','nonlinear_gmap');

figure;
n=129;
gmap=([1:n]./(n*.8))';
gmap=[gmap gmap gmap];
linear_gmap=gmap;
colormap(linear_gmap);colorbar;

save('linear_gmap','linear_gmap');
