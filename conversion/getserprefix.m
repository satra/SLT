function serprefix = getserprefix(scan)

serprefix = [];

switch(scan),
case 'bold',
    serprefix = 'Series';
case '3danat',
    serprefix = 'StructuralSeries';
case {'scout','scout_c22cm'},
    serprefix = 'ScoutSeries';
case {'t1epi','t1conv'},
    serprefix = 'HiResSeries';
otherwise,
end;