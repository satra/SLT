%Mar 13, 1998 09:12
%read_patch(fname)
% fname_patch, fname_real, fname_imag (real and imaginary signal files)
% fname_patch - .patch.asc
%fname_patch='971226JM_fasteccen_lh_real.patch.asc';
%fname_real='x971226JM_fasteccen_lh_real';
%fname_imag='x971226JM_fasteccen_lh_imag';
% $$$ fname_patch='lh.oc.flat.real.patch.asc';
% $$$ fname_real='lh.oc.flat.real';
% $$$ fname_imag='lh.oc.flat.imag';
fclose('all');
fid=fopen(fname_patch,'rt');
s = fgetl(fid);
s = fgetl(fid);
[poly,count] = sscanf(s,'%d');
numvert = poly(1);
numquad = poly(2);
vertex_coordinates = zeros(3,1);
face_index = zeros(4,1);
vertx_list = zeros(numvert,3);
face_list = zeros(numquad,5);
tic;
for vert = 1:1:(numvert),
    s = fgetl(fid);
    vertx = sscanf(s,'%d');
    s = fgetl(fid);
    vertx_coordinates = sscanf(s,'%f');
    vertx_list(vert,:) = [vertx_coordinates(1:2)' vertx];
end;
toc
tic;
for face = 1:1:(numquad),
    s = fgetl(fid);
    facenum = sscanf(s,'%d');
    s = fgetl(fid);
    face_vertx = sscanf(s,'%d');
    face_list(face,:) = [face_vertx' facenum];
end;
toc
fclose(fid);
full_vertx=zeros(max(max(vertx_list))+1,3);
full_vertx(vertx_list(:,3)+1,1)=vertx_list(:,1);
full_vertx(vertx_list(:,3)+1,2)=vertx_list(:,2);
mesh_real=File2Var(fname_real);
vertx_values=zeros(max(max(vertx_list))+1,1);
vertx_values(vertx_list(:,3)+1)=mesh_real(:,5);
mesh_imag=File2Var(fname_imag);
vertx_complex=zeros(max(max(vertx_list))+1,1);
vertx_complex(vertx_list(:,3)+1)=mesh_imag(:,5);
v_complex = vertx_values(:,1) + i*vertx_complex;
v_phase=angle(v_complex');

strpwd=pwd;
subplot(4,3,nfig+1);
title([strpwd((length(strpwd)-25):length(strpwd)) ' ' fname_real]);
p_handle=patch('Vertices',full_vertx,'Faces',face_list(:,1:4)+1,'FaceVertexCData',v_phase','FaceColor','interp','EdgeColor','none');
%colormap(rgb(256));
colorbar;
%tic; t_unwrap=unwrap(angle(v_complex)); toc

short_complex = mesh_real(:,5) + (i*mesh_imag(:,5));
short_unwrap=angle(short_complex);
[zmat,xvec,yvec]=ffgrid(vertx_list(:,1),vertx_list(:,2),short_unwrap,1.0,1.0);
subplot(4,3,nfig+2);
imagesc(xvec,yvec,zmat);
axis xy;
%colormap(rgb(64));
colorbar;
subplot(4,3,nfig+3);
contour(xvec,yvec,zmat,20);
%figure;

%ffgrid(vertx_list(:,1),vertx_list(:,2),short_unwrap,0.75,0.75); 
[zmat_imag,xvec,yvec]=ffgrid(vertx_list(:,1),vertx_list(:,2),mesh_imag(:,5),1.0,1.0);
[zmat_real,xvec,yvec]=ffgrid(vertx_list(:,1),vertx_list(:,2),mesh_real(:,5),1.0,1.0);
smooth_filt = fspecial('average',3);
zmat_imag_smooth = zmat_imag;
zmat_real_smooth = zmat_real;
maxiter=2;
for niter=1:maxiter,
  zmat_imag_smooth = filter2(smooth_filt,zmat_imag_smooth);
  zmat_real_smooth = filter2(smooth_filt,zmat_real_smooth);
end;
zmat_angle_smooth = angle(zmat_real_smooth + (i*zmat_imag_smooth));
subplot(4,3,nfig+5);
imagesc(xvec,yvec,zmat_angle_smooth); axis xy;
subplot(4,3,nfig+6);
contour(xvec,yvec,zmat_angle_smooth,20);
