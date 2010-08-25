function SAMweights = mat_ComputeSAMWeights(gain_matrix, inv_covariance, beamform_method);

% SAMweights = ComputeSAMWeights(gain_matrix, inv_covariance, beamform_method);
%
% computes SAM weights, using either the gain for a single voxel
% orientation (for non-linear beamformer, i.e. SAM) or the gains
% for 2 tangential dipole components gain_matrix contains, in each
% column, the lead field of a dipole. For the non-linear
% beamformer, only one column is used (this is the lead field for
% the dipole with the optimum orientation). For the linear
% beamformer, 2 columns are used (2 tangential orientations) 
%
% inv_covariance: inverse of the data-covariance matrix
% beamform_method: either 'nonlinear' or 'linear'
%
% based on 'Differences between Synthetic Aperture Magnetometry
% (SAM) and Linear Beamformers - J. Vrba and S.E. Robinson, Biomag
% 2000' 

%disp(sprintf('\n%s\t(C) 2002, Arjan Hillebrand, Wellcome Trust Laboratory for MEG Studies, Aston University\n', mfilename));

trgain_invC = gain_matrix' * inv_covariance;
%if strcmp(beamform_method, 'linear') & size(gain_matrix,2)==2
%   SAMweights = ( inv(trgain_invC * gain_matrix) ) * trgain_invC;  
%elseif strcmp(beamform_method, 'linear') & size(gain_matrix,2)~=2
%  error('The gainmatrix should contain the leads of two tangential components for a linear beamformer')    
%elseif strcmp(beamform_method, 'nonlinear') & size(gain_matrix,2)==1


SAMweights =  trgain_invC ./ repmat(sum(trgain_invC .* gain_matrix',2),1,size(inv_covariance,1));

%end    





