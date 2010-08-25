function [A,t] = alignSurfs(r,t,hsv,skull)

% returns rotation and translation to align mri to sensor space
A = [];
t = [];

global maxVertices;     % Defined elsewhere (alignCoordinateFrames.m)
global dirTemplate;

h1 = trisurf(hsv.faces,hsv.vertices(:,1),hsv.vertices(:,2),hsv.vertices(:,3));hold on;
h2 = trisurf(skull.faces,skull.vertices(:,1),skull.vertices(:,2),skull.vertices(:,3),'FaceColor',[0.7 0.7 0.7],'FaceAlpha',0.75);
xlabel('x'); ylabel('y'); zlabel('z');
set(h1,'FaceAlpha',0.5,'FaceColor','interp');
hold on;
axis equal;

% Lower resolution of skull surface
if (length(skull.vertices) > maxVertices)
    fprintf('Reducing the number of vertices in skull surface...\n');
    reducedSkull = reducepatch(skull,maxVertices/length(skull.vertices));
    filesave = ['save ' fullfile(dirTemplate.input,'mriSurfaces.mat'),' reducedSkull -APPEND']
    eval(filesave);
    skull = reducedSkull;
end;
r = 0;
while (r ~= -1)
  r = (input('Enter skull surface rotation vector (-1 to commit last transform): [x_deg y_deg z_deg]: '))';
  if (r ~= -1)
    t = (input('Enter skull surface translation vector: [x_tr y_tr z_tr]; '))';
    if exist('h2')
      delete(h2);
    end;
    [A,skullSurf,t] = rotateSurf(r,t,skull.vertices);
    h2 = trisurf(skull.faces,skullSurf(:,1),skullSurf(:,2),skullSurf(:,3),'FaceColor',[0.7 0.7 0.7],'FaceAlpha',0.75);
    axis equal;
  end;
end;

load('sensors.mat');
sensorLocs = sensorLocs / 1000;
plot3(sensorLocs(:,1),sensorLocs(:,2),sensorLocs(:,3),'ro','MarkerFaceColor','red','MarkerSize',12);