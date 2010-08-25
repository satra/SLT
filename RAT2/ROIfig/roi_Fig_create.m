function roi_Fig_create(results,significance,contrastlist)
% function roi_Fig_create(results,significance,contrastlist)
% creates ROI figures using the roi results structure 'results'
% using a default significance level of 0.05 (unless specified
% directly with significance). If contraslist is empty all figures
% are created. Otherwise only the specified figures are created.

% $Id: roi_Fig_create.m 133 2006-06-03 10:44:25Z labuser $

if nargin<2,
    significance = [];
end
if nargin<3,
    contrastlist = [];
end

% for indefrey levelt style diagrams
if 0,
    jmap = flipud([repmat([238,159,144],64,1);255 255 255;repmat([158,218,244],64,1)]/255);
    [img1,map1,maxFval,jmap] = roi_Fig_create_right(results,contrastlist,[],jmap,significance,0);
    close all;
    [img2,map2,maxFval,jmap] = roi_Fig_create_left(results,contrastlist,[],jmap,significance,0);
    close all;
    roi_Fig_create_both(results,contrastlist,img1,map1,img2,map2,maxFval,[]);
    close all
else,
    [img1,map1,maxFval,jmap] = roi_Fig_create_right(results,contrastlist,[],[],significance);
    close all;
    [img2,map2,maxFval,jmap] = roi_Fig_create_left(results,contrastlist,[],[],significance);
    close all;
    roi_Fig_create_both(results,contrastlist,img1,map1,img2,map2,maxFval,jmap);
    close all
end
if isunix,
    try
        make_cmd = fileparts(which('roi_spmFigures'));
        make_cmd = fullfile(make_cmd,'makepdf.sh');
        if ~isempty(significance),
            significance = round(1000*significance);
            make_cmd = sprintf('%s RESULTS_p%03d_%s',make_cmd,significance, ...
                date);
        else,
            significance = 'default'
            make_cmd = sprintf('%s RESULTS_p%s_%s',make_cmd,significance, ...
                date);
        end;
        system(make_cmd);
    catch
        fprintf('%s\n',lasterr);
    end
end