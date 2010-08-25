function [V1, V2, D1, D2 , initParams, DT] = mat_coregister(tS,refSurf)

% Author: Jay Bohland
% Date: 08/10/03
% This function performs surface based co-registration of a partial surface
% (testSurf) - probably digitized head shape, to a more detailed surface
% (refSurf) - probably extracted from an MR image.  
% Reference:
% Kozinska D, Carducci, F, and Nowinski, K (2001). Automatic alignment of 
% EEG/MEG and MRI data sets, Clinical Neurophysiology 112, 1553-1561.

% Calculate max and min scales for the voxel array used in the distance
% transform
global DT;
global voxArrayLimits;
global testSurf;

testSurf = tS;

voxArrayLimits = round([min(min(testSurf.vertices(:,1)),min(refSurf.vertices(:,1)))-0.2*min(min(testSurf.vertices(:,1)),min(refSurf.vertices(:,1))), ...
                      max(max(testSurf.vertices(:,1)),max(refSurf.vertices(:,1)))+0.2*max(max(testSurf.vertices(:,1)),max(refSurf.vertices(:,1)));
                      min(min(testSurf.vertices(:,2)),min(refSurf.vertices(:,2)))-0.2*min(min(testSurf.vertices(:,2)),min(refSurf.vertices(:,2))), ...
                      max(max(testSurf.vertices(:,2)),max(refSurf.vertices(:,2)))+0.2*max(max(testSurf.vertices(:,2)),max(refSurf.vertices(:,2)));
                      min(min(testSurf.vertices(:,3)),min(refSurf.vertices(:,3)))-0.2*min(min(testSurf.vertices(:,3)),min(refSurf.vertices(:,3))), ...
                      max(max(testSurf.vertices(:,3)),max(refSurf.vertices(:,3)))+0.2*max(max(testSurf.vertices(:,3)),max(refSurf.vertices(:,3)));])
              

V2 = []; 
D2 = [];
fprintf('Calculating centroids for each surface...\n');
c1 = mat_getCentroid(testSurf)'
c2  = mat_getCentroid(refSurf)'

% Calculate translation vector

fprintf('Calculating inertia matrices for each surface...\n');
M1 = mat_getInertiaMatrix(testSurf);
M2 = mat_getInertiaMatrix(refSurf);

[V1, D1] = eigs(M1);
[V2, D2] = eigs(M2);

[initA, initT] = mat_rotsolve(V1,V2);
initParams = [initA c2-c1];

% To compute the distance transform, we must represent refSurf as a voxel
% array.  So, compute a 3-D matrix with entries 1 for a point in the
% surface, 0 for a non-object point.  
% Fix the size of the voxel array (that is, make each dimension span a
% fixed range in mm space) to the size determined for voxArrayDimensions
% above

fprintf('Calculating the Euclidean distance transform for the reference surface...\n');
voxArray = zeros(128,128,128);  % Arbitrary size of voxel array to map vertices into
voxX = (refSurf.vertices(:,1) - (voxArrayLimits(1,1))) ./ (voxArrayLimits(1,2)-voxArrayLimits(1,1));
voxY = (refSurf.vertices(:,2) - (voxArrayLimits(2,1))) ./ (voxArrayLimits(2,2)-voxArrayLimits(2,1));
voxZ = (refSurf.vertices(:,3) - (voxArrayLimits(3,1))) ./ (voxArrayLimits(3,2)-voxArrayLimits(3,1));


% voxX = (refSurf.vertices(:,1)-1.25*min(refSurf.vertices(:,1)))./(1.25*max(refSurf.vertices(:,1))-1.25*min(refSurf.vertices(:,1)));
% voxY = (refSurf.vertices(:,2)-1.25*min(refSurf.vertices(:,2)))./(1.25*max(refSurf.vertices(:,2))-1.25*min(refSurf.vertices(:,2)));
% voxZ = (refSurf.vertices(:,3)-1.25*min(refSurf.vertices(:,3)))./(1.25*max(refSurf.vertices(:,3))-1.25*min(refSurf.vertices(:,3)));
for i=1:length(voxX),
 voxArray(max(1,floor(voxX(i)*size(voxArray,1))),max(1,floor(voxY(i)*size(voxArray,2))),max(1,floor((voxZ(i)*size(voxArray,3))))) = 1;
end;
DT = bwdist(voxArray);

% Now the optimization step - minimize 

options=optimset('Display','iter','DiffMinChange',0.01,'LargeScale','off');
% I think we can pass the testSurf and DT like this as "parameters" using
% lsqnonlin...

fprintf('Running optimization procedure to find best fit...\n');
[optParams,resSSE] = lsqnonlin(@mat_coregCalculateDistance,initParams(:),[],[],options);


