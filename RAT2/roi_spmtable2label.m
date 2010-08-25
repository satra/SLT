%function roi_spm2tal

cluster_probs = spm_table.dat(:,3);

idx = [];
for i=1:size(cluster_probs,1),
    if ~isempty(cluster_probs{i}),
	idx = [idx;i];
    end
end

p = cell2mat(spm_table.dat(idx,10));
xyz = [spm_table.dat{idx,11}];
%xyz_tal = roi_mni2tal(xyz(:,find(p<0.05)));

%V = spm_vol('/speechlab/software/SLT/RAT2/brodmann.img');
V = spm_vol('/speechlab/software/SLT/RAT2/aal.img');
Y = spm_read_vols(V);
idx = find(p<0.05);
xyz_vol = pinv(V.mat)*[xyz(:,idx);ones(1,length(idx))];
xyz_vol = max(round(xyz_vol(1:3,:)),1)';
idx_vol = sub2ind(V.dim(1:3),xyz_vol(:,1),xyz_vol(:,2),xyz_vol(:,3));

[pu_id,pu_label,some_no] =textread('/speechlab/software/SLT/RAT2/aal.txt','%d%s%d\n');

VOX = diag(V.mat);
fprintf('Smoothing [%3d] of [%3d]',0,length(idx_vol));
id = [];
for i=1:length(idx_vol),
    vol = zeros(V.dim(1:3));
    vol(idx_vol(i)) = 1;
    vol = roi_smoothVol(vol,VOX(1:3),3);
    id_smooth = Y(find(vol(:)));
    if sum(id_smooth)>0,
	id(i) = median(id_smooth(find(id_smooth)));
    else
	id(i) = 0;
    end
    fprintf('%s%3d] of [%3d]',sprintf('\b')*ones(1,13),i,length(idx_vol));
end
fprintf('%sDone',sprintf('\b')*ones(1,13));

id = id(:);
idx_valid = find(id);

p_valid = p(idx(idx_valid));
label_valid = pu_label(id(idx_valid)); 
label_id   = num2str(id(idx_valid));
pos_valid = V.mat(1:3,:)*[xyz_vol(idx_valid,:)';ones(1,length(idx_valid))];

strcat(num2str(p_valid),'<---->',char(label_valid),'<---->',num2str(pos_valid'))
%strcat(num2str(p_valid),'<---->',label_id,'<---->',num2str(pos_valid'))

