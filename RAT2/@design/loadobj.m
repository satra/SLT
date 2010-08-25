function dsgn = loadobj(dsgn)

% [Satra: 2June2005]: isfield does not work with objects only with structures, so convert to 
% structure before testing.

if ~isstruct(dsgn)
     dsgn = struct(dsgn);
end

if ischar(dsgn.roiSmoothFWHM),
    dsgn.roiSmoothFWHM = str2num(dsgn.roiSmoothFWHM);
end
if ~isfield(dsgn,'xX_K_LParam'),
    dsgn.xX_K_LParam = 0;
end
if ~isfield(dsgn,'RemoveGlobal'),
    dsgn.RemoveGlobal = 0;
end

dsgn = design(dsgn);
