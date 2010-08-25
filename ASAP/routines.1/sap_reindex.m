function Y2 = sap_reindx(Y,midpt)

Y = fix(round(double(Y)));
Y2 = zeros(size(Y));

idx = unique(Y(:));
idx = idx(2:end);

LRMask = ones(size(Y));
LRMask(1:midpt,:,:) = -1;

PU = sap_PUlist;
load ROI_Database_Labels;
Label = upper(Label);

for count=1:length(idx),
    labelid = idx(count)
    Y1 = (Y==labelid).*LRMask;
    label = PU{labelid};
    labelrt = upper(sprintf('Right%s',label));
    labellt = upper(sprintf('Left%s',label));
    idxrt = find(strncmp(Label(:),labelrt,length(labelrt)));
    idxlt = find(strncmp(Label(:),labellt,length(labellt)));
    leftidx = find(Y1(:)<-0.1);
    if ~isempty(idxlt),
        Y2(leftidx) = idxlt;
    else,
        disp(labellt);
    end;
    rightidx = find(Y1(:)>0.1);
    if ~isempty(idxrt),
        Y2(rightidx) = idxrt;
    else,
        disp(labelrt);
    end;
end;