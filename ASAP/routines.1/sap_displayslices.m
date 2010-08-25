function sap_displayslices(varargin)

switch(nargin)
    case 2,
        vol = varargin{1};
        vol(find(vol(:)<20)) = NaN;
        pos = varargin{2};
        sap_displayslices(squeeze(vol(pos(1),:,:)),squeeze(vol(:,pos(2),:)),squeeze(vol(:,:,pos(3))),pos);
    case 3,
        vol = varargin{1};
        pos = varargin{2};
        figure;colormap(gray);
        subplot(221);imagesc(squeeze(vol(pos(1),:,:))');axis xy;axis off;axis square;axis image;
        title('Saggital');
        subplot(222);imagesc(squeeze(vol(:,pos(2),:))');axis xy;axis off;axis square;axis image;
        title('Coronal');
        subplot(223);imagesc(squeeze(vol(:,:,pos(3)))');axis xy;axis off;axis square;axis image;        
        title('Axial');
    case 4,
        imgx = double(varargin{1});
        imgy = double(varargin{2});
        imgz = double(varargin{3});
        pos   = varargin{4};
        figure('doublebuffer','on');
        hold on;
        xlabel('x');ylabel('y');zlabel('z');view(49,16);
        [y,z,x] = meshgrid(1:size(imgx,1),1:size(imgx,2),pos(1));
        m = mesh(x,y,z,imgx','facecolor','interp','edgecolor','none');
        [x,z,y] = meshgrid(1:size(imgy,1),1:size(imgy,2),pos(2));
        m = mesh(x,y,z,imgy','facecolor','interp','edgecolor','none');
        [x,y,z] = meshgrid(1:size(imgz,1),1:size(imgz,2),pos(3));
        m = mesh(x,y,z,imgz','facecolor','interp','edgecolor','none');
        plot3(pos(1),pos(2),pos(3),'r.');
        hold off;
        axis off;axis square;axis image;colormap gray;
    otherwise,
end;