function [skull, reducedSkull] = getSkullVolume(mriFilename)

global dirTemplate;

load(fullfile(dirTemplate.input,mriFilename),'skull');
skull.vertices = skull.vertices / 1000; % Convert to meters

% Get the lower resolution surface also (if it exists)
reducedSkull = [];
load(fullfile(dirTemplate.input,mriFilename),'reducedSkull');

if (~isempty(reducedSkull))
  reducedSkull.vertices = reducedSkull.vertices; % Convert to meters
end;