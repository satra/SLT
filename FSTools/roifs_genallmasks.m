
spm_defaults;
filenames = spm_get('files',pwd,'*.spt');

fprintf('Generating masks %2d/%2d',0,10);
for i=10, %:size(filenames,1),
    sptfile = deblank(filenames(i,:));
    [pth,nm,xt] = fileparts(sptfile);
    T1file = fullfile(pth,[nm,'.img']);
    sap_command('createmask',sptfile,T1file);
    fprintf('%s%2d/%2d',sprintf('\b')*ones(1,5),i,10);
end;
fprintf('%s...Done\n',sprintf('\b')*ones(1,5));

