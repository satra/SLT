function y = mat_sarvas(q,r,ro,coil_normal);
%% function y = sarvas(q,r,ro);
%%
%% Computes the magnetic field strength based on Sarvas equation in:
%% J. Sarvas, Basic mathematical and electromagnetic concepts of the biomagnetic inverse problem
%% Phys. Med. Biol., Vol32, pp.11-22
%%
%% Input:  q = dipole orientation, should be a unit vector; in units of Am
%%         r = sensor coil position in meters, with respect to the sphere origin
%%         ro = dipole position in meters, with respect to the sphere origin
%% Output: Field strength in Tesla
%%
%% Arjan Hillebrand (hillebra@aston.ac.uk) - Wellcome Trust
%% Laboratory for MEG Studies, Aston University - UK 


a = r - ro;
am = sqrt(a'*a);
rm = sqrt(r'*r);
ff = am*(am*rm+rm^2-ro'*r);
delf = (am^2/rm +(a'*r)/am + 2*am + 2*rm) *r-(am + 2*rm + (a'*r)/am)*ro;
y = (10^-7/(ff^2))*(ff*outer(q,ro)-(outer(q,ro)'*r)*delf);
%y = (10^-7/(ff^2))*(ff*cross(q,ro)-dot(cross(q,ro),r)*delf);
y = y'*coil_normal;

%%%%%%%%%%%%% Comments %%%%%%%%%%%%%%%%%%%%
% For axial gradiometers, you need to use the use the field taken in the 
% direction normal to the coil, i.e. dot(y, coil_normal_vector)       
%
% To get the overall gradiometer output, add/subtract the constribution from each gradiometer coil
%
% Integration over the coil area will increase the accuracy of the computation
% of the gradiometer output(but only slightly)

