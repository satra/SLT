function triggers = KIT160_gettrig(trchan,nochans,ptlen,frlen,thresh,TrigDur)
% an internal funtion for synchronize
% sst_gettrig_inline finds and records triggers
%

% Based on Satra's work
% 01/03/01,		Jia Liu, 	Mass. Inst. of Tech.
 
if nargin == 6,
   dur = round(TrigDur*1.4);
else
   dur = 70; % TrigDur usually is 50ms. SamplingRate 1000Hz.
end


%disp('Finding triggers.');

% The following procedure is faster than diff !!!!
trchan = double(trchan>thresh);
idx = trchan(:,2:size(trchan,2)); % Left shift by one sample
idx = trchan(:,1:size(trchan,2)-1)-idx; % subtract left shifted to get triggers at -1
clear trchan;
idx1 = (idx == -1); % triggers go on
idx2 = (idx == 1); % triggers go off
clear idx;
idx1 = [zeros(nochans,1), idx1]; % right shift by one. voila!!!
idx2 = [zeros(nochans,1), idx2]; % right shift by one. voila!!!

% remove "spurious" triggers, given that there is one and only one 
% gap between on and off should be smaller than round(1 2/5*TrigDur,
% 60 is userd here given ).
if 0,
for i=1:nochans,
   fidx1 = find(idx1(i,:));
   fidx2 = find(idx2(i,:));
   for j=1:length(fidx1),
      sf = find((fidx2 < (fidx1(j)+dur)) & (fidx2>fidx1(j)));
      % the codes for spurious triggers checking is turned off in order to
      % to handle various lengths of triggers. The codes need to be improved
      % in future
      %if (isempty(sf)) | length(sf)>1 ,
      %   idx1(i,fidx1(j)) = 0;
      %   str = sprintf('Spurious Trigger found at %d', fidx1(j));
      %   warndlg(str);
      %end
   end
end
end;

for i=1:nochans,
    multfib(1,i) = fibfun(2*i-1);
end
triggers = multfib*idx1; % trigger magnitude reflects stimuli no.


% Adjust for triggers with not enough sample points
triggers(1:ptlen) = 0;
len = length(triggers);
triggers((len-(frlen-ptlen)+1):len) = 0;
triggers = uint8(triggers);
