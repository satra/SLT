function [data,otl,offset] = sap_preprocess2(H);

H = sap_getcontour2(H);

%load(cfname);

fname = sprintf('corr_%s',H.fname);
V1 = spm_vol(fname);
H.Data1 = uint16(spm_read_vols(V1));
H.Data1 = H.Data1(end:-1:1,:,:);
H.Data = H.Data1;
H = rmfield(H,'Data1');

H.mask = H.mask(end:-1:1,:,:);

idx = find(H.mask);
[x,y,z] = ind2sub(size(H.mask),idx);

H.Image.Crop_X = [max(1,min(x)-5):min(max(x)+5,256)];
H.Image.Crop_Y = [max(1,min(y)-5):min(max(y)+5,256)];
H.Image.Crop_Z = [max(1,min(z)-5):min(max(z)+5,256)];

H.segment1 = H.segment;
ct = 0;
for i=H.Image.Crop_Y,
    ct = ct +1;
    H.segment1(ct).lines = {};
    H.segment1(ct).alive = [];
    for j=1:length(H.segment(i).lines),
        H.segment1(ct).lines{j}.ptlist(:,1) = H.segment(i).lines{j}.ptlist(:,1)-H.Image.Crop_X(1)+1;
        H.segment1(ct).lines{j}.ptlist(:,2) = H.segment(i).lines{j}.ptlist(:,2)-H.Image.Crop_Z(1)+1;
        H.segment1(ct).alive(j) = 1;
    end;
end;
data = H.Data(H.Image.Crop_X,H.Image.Crop_Y,H.Image.Crop_Z);
otl = H.segment1;
offset = [H.Image.Crop_X(1),H.Image.Crop_Y(1),H.Image.Crop_Z(1)];

%save(cfname,'H');