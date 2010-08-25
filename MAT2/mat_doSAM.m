load pCortex.mat;
load sensors.mat;
surf = pCortex;
sensorLocs = sensorLocs / 1000;

tCov = 20;		% Width of time window to compute covariance matrix
pTrig = 200;		% pre trigger duration (ms)
fLength = 700;		% total frame length (including pTrig) (ms)

%data = KIT160_readmegdata('2676-NR-auditory.sqd',[185,186],pTrig,fLength);

Z = zeros(length(surf.vertices),48);
%A = mat_calcleadf(surf.vertices,surf.normals,sensorLocs(1:157,1:3),sensorOris(1:157,1:3),0.05);
load testData.mat
%for i=1:size(data.bcall{1},3),   % for each epoch
for i=1:48,
NC = cov(squeeze(data.bcall{2}(:,1:pTrig,i))');
%  for j=pTrig+1:tCov:fLength,    % for each time window along 'data' section of the epoch
for j=pTrig+110:pTrig+110,
    wData = squeeze(data.bcall{2}(:,j:j+tCov,i));
    C = cov(wData');
    W = mat_ComputeSAMWeights(A,pinv(C),'nonlinear');
    Z(:,i) = mat_Compute_Z_Deviate(W,C,NC,'nonlinear');
  end;  % for j
end; % for i

