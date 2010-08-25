load pCortex.mat;
load sensors.mat;
surf = pCortex;
sensorLocs = sensorLocs / 1000;

tCov = 20;		% Width of time window to compute covariance matrix
pTrig = 200;		% pre trigger duration (ms)
fLength = 700;		% total frame length (including pTrig) (ms)

%data = KIT160_readmegdata('2676-NR-auditory.sqd',[185,186],pTrig,fLength);

Z = zeros(length(surf.vertices),48);
Z1 = zeros(length(surf.vertices),48);
%A = mat_calcleadf(surf.vertices,surf.normals,sensorLocs(1:157,1:3),sensorOris(1:157,1:3),0.05);
load testData.mat
%for i=1:size(data.bcall{1},3),   % for each epoch

for i=1:1,
    %trial_data = squeeze(datausv(:,:,i))';
    trial_data = data.bcavg{2};
    NC = cov(trial_data(:,1:pTrig)');
    %  for j=pTrig+1:tCov:fLength,    % for each time window along 'data' section of the epoch
    C1 = cov(trial_data(:,pTrig+[1:200])');
    W = mat_ComputeSAMWeights(A,pinv(C1),'nonlinear');
    Z1(:,i) = mat_Compute_Z_Deviate_satra(W,NC,NC,'nonlinear');
    for j=pTrig+100:pTrig+100,
	wData = squeeze(trial_data(:,j:j+tCov));
	C = cov(wData');
	Z(:,i) = mat_Compute_Z_Deviate_satra(W,C,NC,'nonlinear');
    end;  % for j
end; % for i

h = zeros(length(surf.vertices),1);
p = ones(length(surf.vertices),1);

%for i=1:size(Z,1)
% [h(i),p(i)] = ttest2(Z1(i,:),Z(i,:));
%end
