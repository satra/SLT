[l,id] = roi_load_labels;
id = id(find(id<32000));   
l = char(l(id));         
l = l(:,6:end);         
l = cellstr(l);    

col = round(255*rand(256,3));

fid = fopen('SpeechLabLabels.txt','wt');
fprintf(fid,'%3d %5s %3d %3d %3d %d\n',0,'None',0,0,0,0);

for j=1:255,
    if j<=length(l),
    fprintf(fid,'%3d %5s %3d %3d %3d %d\n',j,l{j},col(j,1), ...
	    col(j,2),col(j,3),0);
    else,
    fprintf(fid,'%3d %5s %3d %3d %3d %d\n',j,'None',col(j,1), ...
	    col(j,2),col(j,3),0);
    end;
end;
fclose(fid);
