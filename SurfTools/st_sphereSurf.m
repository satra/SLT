function surf = st_sphereSurf(surf,mc,breakcount)
% SURF = ST_SPHERESURF(SURF) converts the surface SURF
% using the mean curvature MC into a sphere.
%
% SURF = ST_SPHERESURF(SURF,MC) uses the curvature information
% provided in the vector MC.
%
% SURF = ST_SPHERESURF(SURF,MC,BREAKCOUNT) stops the expansion
% after BREAKCOUNT number of iterations.
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

if nargin<2,
    surf = st_preprocess(surf);
%    mc = 
end
if nargin<3,
    breakcount = -1;
end;
beta = 0.4;
lambda = 0.5;

Fs = zeros(size(surf.vertices));
Fr = zeros(size(surf.vertices));
DFs=cell(length(Fs),1);
nbs=cell(length(Fs),1);

verts = surf.vertices;
hproc = uiwaitbar('Calculating neighbor info');
for j=1:length(verts),
    nbs{j} = st_neighbors(surf,j);
    if mod(j,100)==0,
        uiwaitbar(j/length(verts),hproc);
    end;
end;
delete(hproc);

diffdist = inf;
count = 0;

while diffdist>0.5,
    count = count + 1;
    verts = surf.vertices;
    centroid = mean(surf.vertices);
    vertNormals = st_computeNormals(surf);
    vvector = verts - repmat(centroid,length(verts),1);
    normalvector = vvector./repmat(sqrt(sum(vvector.*vvector,2)),1,3);
    Rvector = 40*normalvector-vvector;
%    hproc = uiwaitbar('wait');
    for j=1:length(verts),
        DFs{j} = verts(nbs{j},:)-repmat(verts(j,:),length(nbs{j}),1);
        Fs(j,:) = mean(DFs{j});
        Fr(j,:) = sum(DFs{j});
        if mod(j,1000)==0,
%            uiwaitbar(j/length(verts),hproc);
        end;
    end;
%    delete(hproc);
    Fs = Fs-repmat(sum(Fr)/length(verts),length(verts),1);
    magR = sqrt(sum(Rvector.*Rvector,2));
    verts = verts + beta*repmat(magR,1,3).*Fs + lambda*Rvector;
    diffdist = magR'*magR;
    fprintf('diffdist[%f]\n',diffdist);
    surf.vertices = verts;
    showVertexValue(surf, mc);
    drawnow;
    if count == breakcount,
        break;
    end;
end;
