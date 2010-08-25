function [label,info,labelcols] = roifs_annotval2PUval(annotfile)

annot = read_annotation(annotfile);
rgbvals = unique(annot);
label = annot;

SubjectsDir = deblank(getenv('SUBJECTS_DIR'));
FreeSurfDir = deblank(getenv('FREESURFER_HOME'));
%[id,nm,rr,gg,bb,dum] = textread(fullfile(FreeSurfDir,'surface_labels.txt'),'%d%s%d%d%d%d');
%warning('using new freesurfer');
%[id,nm,rr,gg,bb,dum] = textread(fullfile(FreeSurfDir,'average','colortable_desikan_killiany.txt'),'%d%s%d%d%d%d');
[id,nm,rr,gg,bb,dum] = textread(fullfile(FreeSurfDir,'ASAP_labels.txt'),'%d%s%d%d%d%d');
%[id,nm,rr,gg,bb,dum] = textread(fullfile(FreeSurfDir,'Simple_surface_labels2005.txt'),'%d%s%d%d%d%d');

for i=1:size(rgbvals,1),
    hexstr = fliplr(dec2hex(rgbvals(i),6));
    rval = hex2dec(fliplr(hexstr(1:2)));
    gval = hex2dec(fliplr(hexstr(3:4)));
    bval = hex2dec(fliplr(hexstr(5:end)));
    
    idx = intersect(intersect(find(rr==rval),find(gg==gval)), ...
		    find(bb==bval));
    if ~isempty(idx),
      label(find(label==rgbvals(i))) = id(idx);
      info(i,1) = id(idx);
      info(i,2) = length(find(annot==rgbvals(i)));
    else,
      fprintf('could not find value: %d\n',rgbvals(i));
      label(find(label==rgbvals(i))) = 0;
      info(i,1) = 0;
      info(i,2) = length(find(annot==rgbvals(i)));
    end
end
labelcols = [rr,gg,bb]/255;
