function data = mat_baseadjust(avgdata,ptlen,type)
%MAT_BASEADJUST(avgdata, pretrigger_length)
%MAT_BASEADJUST is a routine for creating two baseline adjusted data sets.
%
%data.bc is standard baseline corrected (subtracts average from pretrigger
%        period from whole frame length)
%data.dt is de-trended (regresses out linear trend found over epoch)


if nargin<3,
% do baseline correction
avg = mean(avgdata(:,1:ptlen),2);
data.bc = avgdata-repmat(avg,[1 length(avgdata)]);

% create detrended data
data.dt = detrend(avgdata')';
end;
switch(type),
    case 1,
        avg = mean(avgdata(:,1:ptlen),2);
        data = avgdata-repmat(avg,[1 length(avgdata)]);
    case 2,
        data = detrend(avgdata')';
end
