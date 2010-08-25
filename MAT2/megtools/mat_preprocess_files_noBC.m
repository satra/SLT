conditions{1}.name = 'dGoodR';
conditions{1}.sqdfiles = {'NR-2676-goodR-disc1.sqd',...
                          'NR-2676-goodR-disc2.sqd',...
                          'NR-2676-goodR-disc3.sqd'};
conditions{1}.triggers = [185 186];      % Triggers to average across for this conditions
conditions{1}.preTrigger = 200;
conditions{1}.postTrigger = 1800;
conditions{1}.outputFile = 'bstFiles/2676_data_dGoodR.mat';

conditions{2}.name = 'dAmbig';
conditions{2}.sqdfiles = {'NR-2676-ambig-disc1.sqd',...
                          'NR-2676-ambig-disc2.sqd',...
                          'NR-2676-ambig-disc3.sqd'};
conditions{2}.triggers = [185 186];      % Triggers to average across for this conditions
conditions{2}.preTrigger = 200;
conditions{2}.postTrigger = 1800;
conditions{2}.outputFile = 'bstFiles/2676_data_dAmbig.mat';

conditions{3}.name = 'dGoodL';
conditions{3}.sqdfiles = {'NR-2676-goodL-disc1.sqd',...
                          'NR-2676-goodL-disc2.sqd',...
                          'NR-2676-goodL-disc3.sqd'};
conditions{3}.triggers = [185 186];      % Triggers to average across for this conditions
conditions{3}.preTrigger = 200;
conditions{3}.postTrigger = 1800;
conditions{3}.outputFile = 'bstFiles/2676_data_dGoodL.mat';

% For all data files
ChannelFlag = ones(1,157);
Device = 'KIT/MIT MEG 160';
NoiseCov = [];
Project = [];
Projector = [];
SourceCov = [];

for i=1:length(conditions),
    for j=1:length(conditions{i}.sqdfiles),
        data = KIT160_readmegdata(conditions{i}.sqdfiles{j},conditions{i}.triggers,...
                                  conditions{i}.preTrigger, conditions{i}.postTrigger+conditions{i}.preTrigger+1);
        tempSum = zeros(size(data.avg{1}));
        for k=1:length(data.avg), tempSum = tempSum + data.avg{k}; end;
        bcavg{j} = tempSum / length(data.avg);
    end;
    clear data;
    tempSum = 0;
    for k=1:length(conditions{i}.sqdfiles), tempSum = tempSum + bcavg{k}; end;
    clear bcavg;
    F = tempSum / length(conditions{i}.sqdfiles);
    Time = [-conditions{i}.preTrigger : conditions{i}.postTrigger] / 1000;
    Comment = conditions{i}.name;
    save(conditions{i}.outputFile,'F','ChannelFlag','Comment','Device','Project','Projector','SourceCov','Time');
    clear F;
end;
