function p = showpatch(nfv,col1,col2)
if (nargin<2)
   col1 = [0.7 0.7 0.7];
   col2 = 'none';
 elseif (nargin<3),
   col2 = 'none';
end;

p = patch(nfv,...
   'FaceColor',col1,...
   'EdgeColor',col2);
clear nfv;
%set(p)
%material dull;

if (strcmp(col1,'interp')),

   set(p,'AmbientStrength',0.7);
%   set(p,'AmbientStrength',2,...
%      'DiffuseStrength',1,...
%      'SpecularStrength', 1, ...
%      'SpecularExponent', 0.1,...
%     'SpecularColorReflectance',1);

else,

   set(p,'SpecularColorReflectance',1,'SpecularExponent',50);

%   set(p,'AmbientStrength',2,...
%      'DiffuseStrength',1,...
%      'SpecularStrength', 1, ...
%      'SpecularExponent', 10,...
%     'SpecularColorReflectance',1);

end;

