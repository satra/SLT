function st_slicePatch(v, f, normal, distance, option)
% 
% function slicePatch(v, f, normal, distance, option)
%   -- normal and distance define a plane
%   -- option 1 draws the contour in the current figure
%   -- option 2 opens a new figure, and finds the view s.t.
%      the camera direction is perp to the plane, i.e. so that
%      the contour plane is parallel to the image plane
%
% Mukund Balasubramanium

normal = normal/sqrt(dot(normal, normal));

if option == 2
  figure;
  el = 180/pi*acos(dot(normal, [0 0 1]));
  el = 90-el;
  az = 180/pi*atan2(normal(2), normal(1));
  view(az, el);
  axis equal
end


F = size(f,1);
hproc = waitbar(0,'faces');
for t = 1:F
  nA = f(t, 1);
  nB = f(t, 2);
  nC = f(t, 3);
  
  A = v(nA, :);
  B = v(nB, :);
  C = v(nC, :);
  
  lambda_AB = (distance - dot(A,normal))/(eps + dot((B - A),normal));
  lambda_BC = (distance - dot(B,normal))/(eps + dot((C - B),normal));
  lambda_CA = (distance - dot(C,normal))/(eps + dot((A - C),normal));
  
  P = [];
  if lambda_AB >= 0 & lambda_AB <= 1
    P = [P; A + lambda_AB*(B - A)];
  end
  if lambda_BC >= 0 & lambda_BC <= 1
    P = [P; B + lambda_BC*(C - B)];
  end
  if lambda_CA >= 0 & lambda_CA <= 1
    P = [P; C + lambda_CA*(A - C)];
  end
  if ~isempty(P),
      P1 = P(:,[find(normal==0)]);
    %line(P(:,1),P(:,2),P(:,3));
    line(P1(:,1),P1(:,2),'color','k');
  end
  waitbar(t/F,hproc);
end

close(hproc);
