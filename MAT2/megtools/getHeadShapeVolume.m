function [hsv] = getHeadShapeVolume(hspFilename)

% Create a volume from the hsp file to be used for realignment with mri
% hspFilename : full path and filename for the head shape file from digitizer

% Read the head shape file (ignore 'header' lines)

global dirTemplate; % This information should be specified elsewhere

fid = fopen(fullfile(dirTemplate.input,hspFilename));
if (fid<=0) 
    error('Could not open hsp file');
    return;
end;
for i=1:28 % 28 here skips to beginning of real data
    junk = fgets(fid); % Get one line from the header information, advance file p
end;
coords = fscanf(fid,'%f\t%f\t%f',[3,inf]);
fclose(fid);

% Now transform to the "mri" coordinate frame used by MEG Laboratory
% NO! NO! NO! This coordinate system already matches the MEG sensor coordinate
% system!!!
% coords = coords([2 1 3],:);
% coords(2,:) = -coords(2,:);

% Create a tesselation (faces, vertices) from the head shape coordinates
[th,phi,r] = cart2sph(coords(1,:),coords(2,:),coords(3,:));
rmax = max(r);
[xp1,yp1] = pol2cart(th+pi/2,rmax.*(pi/2-phi));
hsv.faces = delaunay(xp1,yp1);
hsv.vertices = coords';

% Append the head shape volume to the project file
outputFile = fullfile(dirTemplate.output,'hsv.mat');
if (~exist(outputFile))
    fprintf('Writing head shape volume...');
    save(outputFile,'hsv');
end;