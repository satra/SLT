function data = rave_threshscaledata(data,N)

disp(['maxdata: ',num2str(max(abs(data(:))))]);

maxval = abs(rave_input('maxval'));
data = min(max(data,-maxval),maxval);

% Selects the threshold at the outer 'thresh' % of data
% this method improves correspondence between the p values and test values
% [TODO: better explanation required here]
[h,x] = hist(data,min(length(data),256));
ch = cumsum(h)/sum(h);

if any(x<0) & any(x>0),
    idx1 = find(ch<rave_input('thresh')/200);
    idx2 = find(ch>(1-rave_input('thresh')/200));
%    thresh = max(abs([x(idx1(end)) x(idx2(1))]));
elseif all(x>=0),
    idx2 = find(ch>(1-rave_input('thresh')/100));
%    thresh = x(idx2(1));
else,
    idx1 = find(ch<rave_input('thresh')/100);
%    thresh = abs(x(idx1(end)));
end;
%thresh = (100-rave_input('thresh'))*max(abs(data(:)))/100
thresh = rave_input('thresh');

% Which part of the data to display
switch rave_input('show_posneg')
    case -1,
        data = round(N*data.*(data<-thresh)/maxval);
    case 1,
        data = round(N*data.*(data>thresh)/maxval);
    case 0,
        data = round(N*data.*(abs(data)>thresh)/maxval);
    otherwise,
        disp('rave_display_standard: incorrect show_posneg value');
end
