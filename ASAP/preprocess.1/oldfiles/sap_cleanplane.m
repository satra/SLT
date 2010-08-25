function data = sap_cleanplane(data)

[x1 y1] = meshgrid(linspace(1,size(data,2),512),linspace(1,size(data,3),512));
[x2 y2] = meshgrid(linspace(1,512,size(data,2)),linspace(1,512,size(data,3)));
[size(x1) size(y1) size(x2) size(y2) size(data)]

for i=1:size(data,1),
    tmp =[];
    tmp = interp2(squeezeu8(data(i,:,:)),y1,x1,'*nearest');
    tmp = medfilt2(tmp);
    tmp = interp2(tmp,y2,x2,'*nearest');
    data(i,:,:) = tmp;
    fprintf('%d',i);
    if (mod(i,20) == 0),
        fprintf('\n');
    end;
end;