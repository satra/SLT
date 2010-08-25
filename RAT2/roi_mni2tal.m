function outpts = roi_mni2tal(inpts)
%----------------------------------------------------------------------------------
% FORMAT outpts = ihb_mni2tal(inpts)
% Based on mni2tal written by Matthew Brett 10/8/99
% see  The MNI brain and the Talairach atlas on
% http://www.mrc-cbu.cam.ac.uk/Imaging/
%----------------------------------------------------------------------------------
% inpts  - 3xN matrix of MNI coordinates
% outpts - 3XN matrix of Talariach coordinates
%----------------------------------------------------------------------------------
%   01.03.01    Sergey Pakhomov
%----------------------------------------------------------------------------------
upM = [0.9900         0         0         0;...
            0    0.9688    0.0460         0;...
            0   -0.0485    0.9189         0;...
            0         0         0    1.0000];
         
dnM = [0.9900         0         0         0;...
            0    0.9688    0.0420         0;...
            0   -0.0485    0.8390         0;...
            0         0         0    1.0000];
    
avM = [  0.88         0         0     -0.80;...
            0      0.97         0     -3.32;...
            0      0.05      0.88     -0.44;...
            0         0         0      1.00];
    
tmp = inpts(3,:)<0;  % 1 if below AC
inpts = [inpts; ones(1, size(inpts, 2))];
inpts(:,  tmp) = dnM * inpts(:,  tmp);
inpts(:, ~tmp) = upM * inpts(:, ~tmp);
outpts = inpts(1:3, :);
