function mc = st_abscurvature(surf,mc,method)
% [MC] = ST_ABSCURVATURE(SURF,MC,METHOD) computes the absolute
% curvature of the surface based on the mean curvature of the
% surface. The absolute curavture primarily uses a diffusive
% boundary forming algorithm that prevents further diffusion once
% the boundaries have been stabilized.
%
% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

maxp = 0;
minp = 0;

g1 = inline(sprintf('(mc>=(%f*max(mc)))-(mc<(%f*min(mc)))',maxp,minp),'mc');
g2 = inline('abs(mc)>0.7','mc');
gfunc = g1;

% Assign smoothing operator depending on input arguments
% default is vertex smoothing
smoothfunc = @st_smoothVertexValue;
if nargin>2,
    if method == 2,
        smoothfunc = @st_mediancurvfilter;
    end;
end;

mc = gfunc(mc);
mc2 = mc;
prev_mc = mc;
prev_dot = mc'*mc;
diff = inf;
while diff>1,
    mc = feval(smoothfunc,surf, mc,1);
    mc = gfunc(mc);

    cur_dot = mc'*prev_mc;
    diff = abs(prev_dot-cur_dot);
    
    prev_dot = cur_dot;
    prev_mc = mc;
end;
