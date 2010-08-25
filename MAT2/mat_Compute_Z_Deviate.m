function pseudo_Z = mat_Compute_Z_Deviate(SAMweights, covariance, noise_covariance, beamform_method);

% pseudo_Z = Compute_Z_Deviate(SAMweights, covariance, noise_covariance, beamform_method);
%
% SAMweights contains the weights output of
% ComputeSAMWeights. Assumes SAMweights are in rows for each voxel
% (i.e. nr of columns = nr of channels) 
% covariance: data-covariance matrix 
% noise_covariance: the noise-covariance matrix. Note that this
% can be a unity matrix, i.e. it is used to account for the
% non-uniform sensitivity of the MEG sensors (i.e. set:
% noise_covariance = diag(ones(1,length(covariance))) ) 
% beamform_method: either 'nonlinear' or 'linear' 
%
% based on 'Differences between Synthetic Aperture Magnetometry
% (SAM) and Linear Beamformers - J. Vrba and S.E. Robinson, Biomag
% 2000' 

disp(sprintf('\n%s\t(C) 2002, Arjan Hillebrand, Wellcome Trust Laboratory for MEG Studies, Aston University\n', mfilename));

pseudo_Z=[];
if strcmp(beamform_method, 'linear')
  for i=1:size(SAMweights, 1)/2   
    if i/100==floor(i/100),
      disp(sprintf('Computing Z-deviate for %d out of %d', i, size(SAMweights, 1)/2))
    end
    ind1 = (2*i)-1; ind2 = 2*i; 
    P = trace(SAMweights(ind1:ind2,:) * covariance * SAMweights(ind1:ind2,:)');
    N = trace(SAMweights(ind1:ind2,:) * noise_covariance * SAMweights(ind1:ind2,:)'); 
    pseudo_Z(i) = sqrt(P/N); 
  end
elseif strcmp(beamform_method, 'nonlinear')
    P = sum(SAMweights .* (covariance * SAMweights')',2);
    N = sum(SAMweights .* (noise_covariance * SAMweights')',2); 
    pseudo_Z = sqrt(P./N); 
end


