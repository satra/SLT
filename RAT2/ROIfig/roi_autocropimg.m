function autocropimg(img_fname,format)
if nargin<2,
    format = 'tiff';
end

%img_fname = 'lh.contrast_CV-B.jpg';

[img,map] = imread(img_fname);
%figure;imagesc(img);

img1 = sum(img,3);
[x,y] = find(img1<765);

spacex = 5;
spacey = 10;
l= max(min(x)-spacex,1);
r= min(max(x)+spacex,size(img,1));
b= max((y)-spacey,1);
t= min(max(y)+spacey,size(img,2));
img = img(l:r,b:t,:);

%figure;imagesc(img);
switch (format)
    case 'jpeg',
        imwrite(img,img_fname,format,'quality',100);
    otherwise
        imwrite(img,img_fname,format,'Resolution',[600 600]);
end




