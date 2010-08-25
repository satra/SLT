function [residuals] = mat_coregCalculateDistance(x0)

global DT;
global voxArrayLimits;
global testSurf;

% The input parameters are (1) all the affine parameters in a column vector, 
% (2) ts - the test surface (vertices only)
% (3) DT - the distance transform for the reference surface
% (4) voxArrayLimits - the voxel array limits

% What this function needs to do:
% 1. Pass the test surface through the affine transform determined by the
% current parameter set.
% 2. Translate the surface based representation to a 3-d voxel array
% 3. Look up the distance from each point in the new voxel array to the
% reference surface using the distance transform 3-d matrix
% 4. Return a vector of the objective function values (these distances for
% on voxels in the transformed test surface

% Notes: do the distance transform and the testSurface have to be declared
% globally?  How else to get them to this function?

% Possibly we can pass "parameters" to this function also....

% recast the parameters into a familiar affine form

fprintf('Inside Optiming function\n');
format long;
M = reshape(x0,3,4);
A = M(:,1:3);
t = M(:,4);

size(A*testSurf.vertices')
newV = A*(testSurf.vertices)' + repmat(t,1,length(testSurf.vertices));

voxArray = zeros(128,128,128);

voxX = (newV(1,:) - (voxArrayLimits(1,1))) ./ (voxArrayLimits(1,2)-voxArrayLimits(1,1));
voxY = (newV(2,:) - (voxArrayLimits(2,1))) ./ (voxArrayLimits(2,2)-voxArrayLimits(2,1));
voxZ = (newV(3,:) - (voxArrayLimits(3,1))) ./ (voxArrayLimits(3,2)-voxArrayLimits(3,1));

for i=1:length(voxX),
 voxArray(min(max(1,floor(voxX(i)*size(voxArray,1))),size(voxArray,1)),min(max(1,floor(voxY(i)*size(voxArray,2))),size(voxArray,2)),...
          min(max(1,floor((voxZ(i)*size(voxArray,3)))),size(voxArray,3))) = 1;
end;

residuals = DT.*voxArray;
residuals = residuals(:);

sum(residuals.^2)
