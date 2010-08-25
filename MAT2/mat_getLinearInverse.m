function [W] = mat_getLinearInverse(LEADFIELD,SRCCOV,SENSCOV)

% W = mat_getLinearInverse(A) calculates the linear minimum norm
% inverse operator (see Dale et al 2000) given a lead field matrix
% A.  This also allows for adding constraints to the problem via
% the source covariance matrix (R) and the sensor covariance matrix
% (C).
%
%   LEADFIELD   NxM
%   SRCCOV      NxN
%   SENSCOV     MXM
 
% Jay Bohland (jbohland@cns.bu.edu)
% (c) SpeechLab, Boston University, 2003

if (nargin < 2)
    SRCCOV = speye(size(LEADFIELD,2));
    SENSCOV = speye(size(LEADFIELD,1));
elseif (nargin < 3)
    SENSCOV = speye(size(LEADFIELD,1));
end;

W = SRCCOV * LEADFIELD' * inv(LEADFIELD * SRCCOV * LEADFIELD' + SENSCOV);
