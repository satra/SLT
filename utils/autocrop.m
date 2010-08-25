function info = autocrop(data)

info.x_prof = find(squeeze(sum(sum(data,2),3)));
info.y_prof = find(squeeze(sum(sum(data,1),3)));
info.z_prof = find(squeeze(sum(sum(data,1),2)));




