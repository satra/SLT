function [sqddata] = KIT160_readmegdata(fname,channels,ptlen,frlen) 

% fname   : SQUID filename
% channels: 0-based index of trigger channels
% ptlen   : Pre-trigger length in ms
% frlen   : Total frame length including pretrigger in ms

% Works best with nonoverlapping triggers. For overlapping
% triggers, it uses alternate numbers from a fibonacci sequence
% such that the sum of two numbers is never a number in the sequence

if nargin<1,
    % Script testing scenario
    channels = [185,186];
    fname = '2676-NR-auditory.sqd';
    ptlen = 100;
    frlen = 300;
end

% Generate trigger information.
T1 = KIT160_readtrig(fname,channels);
T2 = KIT160_gettrig(T1,length(channels),ptlen,frlen,170,100);

%for Tchan=1:size(T1,1),
%    Trig{Tchan} = KIT160_gettrig(T1(Tchan,:),1,ptlen,frlen,170,50);
%end
%T2 = 1;
%for Tchan=1:size(T1,1),
%    T2 = T2 | Trig{Tchan};
%end

(unique(T2))

% Extract out each trigger channel onset from the trigger
% information. 
for j=setdiff(unique(T2),[0]),
    TrigStim{j} = find(T2==j);
    TrigOnset(j) = TrigStim{j}(1);
end;

% Channel parameters to convert A/D signal to fT
load('chanGain160');
M = diag([gain(1:157);0;0;0]*50/2048);

% Extract raw data and average it
for j=1:length(TrigStim),
    rawdata{j} = zeros(160,frlen,length(TrigStim{j}));
    for i=1:length(TrigStim{j}),
        rawdata{j}(:,:,i) = M*KIT160_getsqddata(fname,TrigStim{j}(i)-ptlen,frlen);
    end;
    rawdata{j} = rawdata{j}(1:157,:,:);
    avgdata{j} = squeeze(mean(rawdata{j},3));
end;


% Extract baseline corrected and detrended data
for j=1:length(TrigStim),
    bc1{j} = zeros(157,frlen,length(TrigStim{j}));
    dt1{j} = zeros(157,frlen,length(TrigStim{j}));
    for i=1:length(TrigStim{j}),
        bc1{j}(:,:,i) = mat_baseadjust(squeeze(rawdata{j}(:,:,i)),ptlen,1);
        dt1{j}(:,:,i) = mat_baseadjust(squeeze(rawdata{j}(:,:,i)),ptlen,2);
    end;
    bc{j} = squeeze(mean(bc1{j},3));
    dt{j} = squeeze(mean(dt1{j},3));
end;

sqddata.raw     = rawdata;
sqddata.avg     = avgdata;
sqddata.bcall   = bc1;
sqddata.dtall   = dt1;
sqddata.bcavg   = bc;
sqddata.dtavg   = dt;
