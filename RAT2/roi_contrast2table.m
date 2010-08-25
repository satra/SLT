function roi_contrast2table(xSPM,outfile);

spm_defaults;
filename1 = fullfile(xSPM.swd,xSPM.Vspm.fname);
[s,r] = strtok(xSPM.Vspm.fname,'_');
if (xSPM.STAT == 'T'),
  filename2 = fullfile(xSPM.swd,['con',r]);
elseif (xSPM.STAT == 'F'),
  filename2 = fullfile(xSPM.swd,['ess',r]);
else
  fprintf('Unknown contrast type: %s\n',xSPM.STAT)
  return;
end

Tval = xSPM.u;
contrast_name = xSPM.title;

if (xSPM.STAT == 'T'),
  contrast_details = sprintf('%s T[%f]',contrast_name,Tval);
elseif  (xSPM.STAT == 'F'),
  contrast_details = sprintf('%s F[%f]',contrast_name,Tval);
end
V1 = spm_vol(filename1);
Y1 = spm_read_vols(V1);
V2 = spm_vol(filename2);
Y2 = spm_read_vols(V2);

%idx_vol = find(Y1(:)<-Tval);
idx_vol = find(Y1(:)>Tval);
[x,y,z] = ind2sub(V1.dim(1:3),idx_vol);

xyz = [x,y,z]';
xyz = V1.mat(1:3,:)*[xyz;ones(1,size(xyz,2))];

if ~isempty(xyz),
    [label,idx,pval] = roi_statxyz2label(xyz,Y1(idx_vol), ...
					 Y2(idx_vol));
    if isempty(pval),
	xyz = [];
    end
end

if ~isempty(xyz),
    T_valid = Y1(idx_vol(idx));
    T_valid_effect_size = Y2(idx_vol(idx));
    label_valid = label;
    pos_valid = xyz(:,idx);
    
    [T_valid_effect_size,sortidx] = sort(T_valid_effect_size);
    T_valid     = T_valid(sortidx);
    label_valid = label_valid(sortidx);
    pos_valid   = pos_valid(:,sortidx);
    pval        = pval(sortidx);
end

if nargin==2,
    diary(outfile);
end
hrule = char(sprintf('=')*ones(1,80));
fprintf('%s\n',hrule);
fprintf('Contrast: %s\n',contrast_details)
fprintf('%s\n',hrule);
fprintf('%-6s\t%-6s\t%-6s\t%-30s\t%-20s\n','Effect','T-val','Reg-p','PU','Locations(mm)');
fprintf('%s\n',hrule);

if isempty(xyz),
    fprintf('No voxels survived threshold\n');
    fprintf('%s\n',hrule);
    if nargin==2,
	diary('off');
    end
    return
end

for n0=1:size(T_valid,1),
    fprintf('%2.2f  \t%2.2f  \t%.2f  \t%-22s\t%4d\t%4d\t%4d\n', ...
	    T_valid_effect_size(n0),...
	    T_valid(n0),pval(n0),label_valid{n0}, ...
	    pos_valid(1,n0),pos_valid(2,n0),pos_valid(3,n0));
    %strcat(num2str(T_valid),'<---->',char(label_valid),'<---->',num2str(pos_valid'))
end
fprintf('%s\n',hrule);
if nargin==2,
    diary('off');
end
