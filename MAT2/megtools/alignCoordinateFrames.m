% This file makes the necessary calls to align the cortical surface to MEG sensor space

global dirTemplate

dirTemplate.input = '/speechlab/3/jbohland/MEG_SP_PILOT/data/';
dirTemplate.output = '/speechlab/3/jbohland/MEG_SP_PILOT/analysis/';

global maxVertices
maxVertices = 15000;    % Max number of skull vertices to be used in realign plots
                        % Reduce this number for faster plotting, poorer resolution

warning off;            % Disable annoying OpenGL messages

hspFilename = 'sp01-shape.hsp';  % Created by MIT digitizer (.hsp extension)
mriFilename = 'sp01_mriSurface.mat';  % Created by us, containing skull, cortex surfaces
sensorFilename = 'sensors.mat';   % Use the default file unless sensors have been moved
markerFilename = 'markersRun1.mat';   % File we create contains marker positions in sensor, digitizer space
hsv = getHeadShapeVolume(hspFilename); % Get data from .hsp file and create surface

hsv = hsv2meg(hsv,markerFilename,[1 2 3]); % Realign head shape to sensor space

[skull,reducedSkull] = getSkullVolume(mriFilename); % Get the skull surface only (in units of m)

if ~isempty(reducedSkull)
    fprintf('Found reduced resolution skull surface.  Using this one....\n');
    [A,t] = alignSurfs([0 0 0]',[0 0 0]',hsv,reducedSkull); % Run the utility to visually align skull,headshape
else
    [A,t] = alignSurfs([0 0 0]',[0 0 0]',hsv,skull); % Run the utility to visually align skull,headshape
end;

