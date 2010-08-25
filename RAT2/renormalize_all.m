function renormalize_all(expt,sid)

if nargin<2 | isempty(sid), 
    sid = 1:length(expt.subject);
end

spm_defaults;
%filenames = spm_get('files',pwd,'corr_*.img');
%filenames1 = spm_get('files',pwd,'nROImask_corr_*.img');

fprintf('Renormalizing masks %2d/%2d',0,length(sid));
for i=sid(:)',
    T1file = spm_get('files',pwd,sprintf('corr_*%02d.Series*.img',i));
    maskfile = expt.subject(i).roidata(1).mask;

    roi_affinenormalize_subject(T1file,maskfile,1);
    fprintf('%s%2d/%2d',sprintf('\b')*ones(1,5),i,length(sid));
end;
fprintf('%s...Done\n',sprintf('\b')*ones(1,5));
