function contrast = contrast_setup_trigger01;

contrast = add_contrast(      [],[1 -1 0],['A-B']      ,'T');   
contrast = add_contrast(contrast,[1 0 -1],['A-Silence'],'T');   

function contrast = add_contrast(contrast,c,name,stat);
if isempty(contrast),
    contrast(1).c      = c;
else
    contrast(end+1).c    = c;
end
contrast(end).name   = name;
contrast(end).stat   = stat;   
