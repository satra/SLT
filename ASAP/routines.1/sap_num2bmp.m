function bmp = sap_num2bmp(num)
numd{1} = ['010101101101010'];
numd{2} = ['010010010010010'];
numd{3} = ['111001010100111'];
numd{4} = ['111001010001111'];
numd{5} = ['101101111001001'];
numd{6} = ['111100111001111'];
numd{7} = ['111100111101111'];
numd{8} = ['111001001010010'];
numd{9} = ['010101010101010'];
numd{10}= ['111101111001001'];

bmp = [];
for j=sprintf('%03d',num),
    setbits = numd{str2num(j)+1};
    setbits = reshape(setbits,3,5)';
    numbmp = zeros(5,3);
    numbmp(find(setbits=='1'))=1;
    bmp = [bmp,zeros(5,1),numbmp,zeros(5,1)];
end;