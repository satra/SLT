function c = outer (a, b)
%  calculate outer product of three-d vector a and b. Faster than Matlab's
%  version.
c=zeros(1,3);
c1=a(2)*b(3)-b(2)*a(3);
c2=a(3)*b(1)-b(3)*a(1);
c3=a(1)*b(2)-b(1)*a(2);
c=[c1; c2; c3];
