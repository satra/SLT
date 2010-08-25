function leadfield = calcleadf(srcloc,srcori,sensloc,sensori,baseline)
% LEADFIELD = CALCLEADF(SRCLOC,SRCORI,SENSLOC,SENSORI,BASELINE) calculates
% the LEADFIELD (T) for the sensor configuration described by SENSLOC (m),
% SENSORI (unit normals) and BASELINE (m) given sources described by SRCLOC
% (m) and SRCORI (unit normals). This calculation is specifically setup for
% axial gradiometers using Sarvas'law and not accounting for the area of
% coil. It is based on the assumption of unit dipoles situated at SRCLOC.
%  
%   LEADFIELD   NxM
%   SRCLOC      Mx3
%   SRCORI      Mx3
%   SENSLOC     Nx3
%   SENSORI     Nx3
%   BASELINE    1x1
%
% The routine for calculating Sarvas' law was provided by Dr. Arjan
% Hillebrand and has been modified to perform matrix computations in order
% to increase speed.

% Satrajit S. Ghosh (satra@bu.edu)
% (c) SpeechLab, Boston University, 2003

numsrc  = size(srcloc,1);   % Number of sources
numsens = size(sensloc,1); % Number of sensors
leadfield = zeros(numsens,numsrc);  % Size of leadfield matrix

% Get position of second coil for axial gradiometers
sensloc2 = sensloc+baseline*sensori;

% Iterate through sources to determine lead field
% Another possibility that might reduce the time would be to iterate
% through sensors instead.
for n0 = 1:numsrc,
    q   = srcori(n0,:)';
    ro  = srcloc(n0,:)';
    
    % For an axialgradiometer the leadfield is determined by a subtraction
    % of the signal at the far coil from the nearer coil.
    leadfield(:,n0) = sarvasM(q,sensloc,ro,sensori)-sarvasM(q,sensloc2,ro,sensori);
    
    pack;   % improves speed of execution by reducing memory fragmentation
end

% Previous code which iterated through sensors in addition to sources.
% [Much, much slower]
%     for n1 = 1:numsens,
%         cn  = sensori(n1,:)';
%         r1  = sensloc1(n1,:)';
%         r2  = sensloc2(n1,:)';
%         leadfield(n0,n1) = sarvas(q,r1,ro,cn)-sarvas(q,r2,ro,cn);
%     end
