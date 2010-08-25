function gwif2 = getGWIF(h);
% GETGWIF Determines the value of the gray-white interface using an EM
%   algorithm.
% Determine the distributions of:
%   gray matter, white matter and anything else
% using an EM algorithm
%   Sort of a hack for the type of data we get. Needs to be tested on different
%   machines and sequences of T1 images

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/preprocess.1/getGWIF.m 2     10/08/02 2:36p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

Nb = 2;      % Number of distributions
N = length(h);
f = convn(h,hamming(14),'same');    % smooth the histogram

% Initialize the EM data structure
beta0 = [ones(Nb,1)/Nb,linspace(1,N,Nb)',4*ones(Nb,1)];

% determine the distribution
[beta,g]=sap_gmem(1:N,f,beta0);

% sort the distributions based on their centers in
% ascending order
beta = sortrows(beta,2);

%plot(x,h,x,g,'r');

% Get the means
gmean   = round(beta(1,2)); % mean gray value
wmean   = round(beta(2,2)); % mean white value

% gwif = Gray-White Interface Value

% determine gray-white cutoff based on minimum value
[miny,idx] = min(g(gmean:wmean));
gwif2  = (gmean+idx);

gwif2 = [gwif2 min([wmean+(wmean-gwif2) length(h)])];
% determine gray white cutoff as the mean of the gray and white centers
% This seems to work better than the above.
%gwif2  = mean([gmean wmean]);
