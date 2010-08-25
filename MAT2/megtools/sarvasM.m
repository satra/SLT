function y = sarvasM(q,r,ro,cn);
%% function y = sarvas(q,r,ro,cn);
%%
%% Computes the magnetic field strength based on Sarvas equation in:
%% J. Sarvas, Basic mathematical and electromagnetic concepts of the biomagnetic inverse problem
%% Phys. Med. Biol., Vol32, pp.11-22
%%
%% Input:  q = dipole orientation, should be a unit vector; in units of Am
%%         r = sensor coil positions in meters, with respect to the sphere
%%         origin (Nx3)
%%         ro = dipole position in meters, with respect to the sphere origin
%%         cn = sensor coil orientations (Nx3)
%% Output: Field strength in Tesla
%%
%% Arjan Hillebrand (hillebra@aston.ac.uk) - Wellcome Trust Laboratory for MEG Studies, Aston University - UK

% Modifications
% Matrix based method that calculates the field at all the sensors
% simultaneously. Also incorporates a direct computation of cross which
% saves time.

ns = size(r,1);

oq = outer(q,ro);
oq = oq(:,ones(1,ns))';
ro = ro(:,ones(1,ns))';

a = r - ro;
am = sqrt(sum(a.*a,2));
rm = sqrt(sum(r.*r,2));
ff = am.*(am.*rm+rm.^2-sum(ro.*r,2));
ff = ff(:,ones(1,3));

c1 = ((am.^2)./rm +sum(a.*r,2)./am + 2*am + 2*rm);
c1 = c1(:,ones(1,3));
c2 = (am + 2*rm + sum(a.*r,2)./am);
c2 = c2(:,ones(1,3));

delf = c1.*r-c2.*ro;
c3 = sum(oq.*r,2);
c3 = c3(:,ones(1,3));

y = ((10^-7)./(ff.^2)).*(ff.*oq-c3.*delf);
y = sum(y.*cn,2);

%%%%%%%%%%%%% Comments %%%%%%%%%%%%%%%%%%%%
% For axial gradiometers, you need to use the use the field taken in the 
% direction normal to the coil, i.e. dot(y, coil_normal_vector)       
%
% To get the overall gradiometer output, add/subtract the constribution from each gradiometer coil
%
% Integration over the coil area will increase the accuracy of the computation
% of the gradiometer output(but only slightly)