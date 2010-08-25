function labelmask = sap_getlabelmask(regdata,sx,sz,lrmask,midpt,val2add,uselineno)

%TODO Fix annular labels by actually creating zero label masks

numlines = length(regdata.lines);
multf = 1;
labelled = 0;
if nargin<4,
    lrmask = 0;
end;
if nargin<5,
    midpt = 0;
end
if nargin<6,
    val2add = 0;
end
if nargin<7,
    uselineno = 0;
end;

if numlines>0,
    mask = zeros(256,256);
    for j=1:numlines,
        %regdata(i).lines{j}.label;
        if ~strcmp(regdata.lines{j}.label,'None') | uselineno,
            if uselineno,
                labelid = j;
            else,
                labelid = regdata.lines{j}.labelid;
            end;
            if lrmask,
                pts = regdata.lines{j}.ptlist;
                x = fix(mean(pts(:,1)));
                if x < midpt,
                    labelid = val2add+labelid;
                end;
            end;
            tmp = double(labelid)*double(bwfill(sap_getmask(regdata.lines(j),[],multf),'holes'))';
            mask = mask+tmp+0.1*(tmp>0);
            labelled = 1;
        end;
    end;
    mask2 = mask-fix(mask);
    idx = find(mask2(:)>0.15);
    mask(idx) = 0;
    labelmask = uint16(fix(mask(1:sx,1:sz)));
end;
if ~labelled,
    labelmask = [];
end;
