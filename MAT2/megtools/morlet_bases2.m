function m = morlet_bases2(freq_vec,Fs,width)

for j=1:length(freq_vec),
    f = freq_vec(j);
    dt = 1/Fs;
    sf = f/width;
    st = 1/(2*pi*sf);
    t=-3.5*st:dt:3.5*st;
    m{j} = morlet_a(t,f,width);
end;

function m = morlet_a(t,f,width);
sf = f/width;
st = 1/(2*pi*sf);
A = 1/(st*sqrt(2*pi));

m = A*exp(-t.^2/(2*st^2)).*exp(i*2*pi*f.*t);