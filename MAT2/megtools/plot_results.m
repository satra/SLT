function plot_results(dHeadData,dMarkers,sMarkers,sForward,sourceLocs,numShells)

% dHeadData - head shape data (N x 3) matrix in FastTrak digitizer space
% dMarkers - (3 x 3) matrix where each column is x;y;z; of one marker in digitizer space
% sMarkers - (3 x 3) matrix where each column is x;y;z; of one marker in sensor (MEG) space
% sForwardTess - struct containing fields 'Vertices' and 'Faces'
% sourceLocs - (1 x N) cell array of locations of N sources, each cell is a 3x1 array (x;y;z)
% numShells - the number of forward model shells that you would like shown

% First transform the head shape (digitizer space) into sensor space
% Solve for the best (LMS) rigid body transform between digitizer and sensor spaces
[A,b] = mat_rotsolve(dMarkers,sMarkers);

sHeadData = A*dHeadData' + repmat(b,1,length(dHeadData));   % Project head data points into sensor space

% Create a tesselation of the head data
[th,phi,r] = cart2sph(sHeadData(4,:),sHeadData(5,:),sHeadData(6,:));
rmax = max(r);
[xp1,yp1] = pol2cart(th+pi/2,rmax.*(pi/2-phi));
tri = delaunay(xp1,yp1);

% Draw the head shape in sensor space
figure;
head = trisurf(tri,sHeadData(4,:),sHeadData(5,:),sHeadData(6,:));
view(145,15)
camzoom(1)
xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis');
hold on;

% Draw the forward model tesselation(s) in sensor space
for i=1:min(length(sForward.Faces),numShells),
    model = trisurf(sForward.Faces{i},sForward.Vertices{i}(:,1),sForward.Vertices{i}(:,2),sForward.Vertices{i}(:,3));
    set(model,'FaceAlpha',0.0,'EdgeAlpha',0.05,'EdgeColor','blue');
    hold on;
end;

fidplot = plot3(sMarkers(1,:),sMarkers(2,:),sMarkers(3,:),'ko','MarkerSize',12,'MarkerFaceColor','black');
set(head)
set(head,'FaceAlpha',0.5,'FaceColor','interp','FaceLighting','none', ...
    'EdgeAlpha',1.0,'FaceLighting','Phong')

for i=1:length(sourceLocs),
 plot3(sourceLocs{i}(1),sourceLocs{i}(2),sourceLocs{i}(3),'kd','MarkerSize',12,'MarkerFaceColor','black');
end;

% Draw the head shape in sensor space
load goodTesselation.mat;
head = trisurf(Faces{1},Vertices{1}(:,1),Vertices{1}(:,2),Vertices{1}(:,3));
set(head,'FaceAlpha',0.5,'EdgeColor','none');
