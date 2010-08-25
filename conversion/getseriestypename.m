function sername = getseriestypename(hdr)

[scanseq,scantype,c,d] = textread('scanseq.unpackcfg','%s%s%s%s');
seqname = deblank(fliplr(strtok(fliplr(hdr.h_G19_Acq4_CM_SequenceFileName),'/')));

idx = find(strcmp(seqname,scanseq));

if isempty(idx),
    sername = 'NoScanInfoSeries';
    return;
elseif  length(idx)>1,
    sername = 'MultipleMatchSeries';
    return;
end;

switch(scantype{idx}),
case 'bold',
    sername = 'Series';
case '3danat',
    sername = 'StructuralSeries';
case {'scout','scout_c22cm'},
    sername = 'ScoutSeries';
case {'t1epi','t1conv'},
    sername = 'HiResSeries';
otherwise,
    sername = ['v',scantype{idx},'Series'];
end;