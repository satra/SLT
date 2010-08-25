function fig = rave_displaysurf(surf,mc,map,map2)
% RAVE_DISPLAYSURF Performs the final display
% See also RAVE_DISPLAY, RAVE_DISPLAY_*

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /RAVE/rave_displaysurf.m 1     12/13/02 5:48p Satra $

% $NoKeywords: $

% Set up the figure, appropriate colormap and the axis
%fig = findobj('Tag','RAVE_FIGURE');
%if isempty(fig),
%    fig = figure('Tag','RAVE_FIGURE','NumberTitle','Off','Name','RAVE DISPLAY');
%end;

colormap(map);
%clf
axis off
axis vis3d
axis equal
%axis tight;

% Draw the patch
p = patch(surf,'FaceVertexCdata',mc,...
    'facecolor','interp','edgecolor','none',...
    'Cdatamapping','direct','Facealpha',rave_input('surf_alpha'));

% Show edges if patch is small
if length(surf.vertices) > 2500
  set(p, 'EdgeColor', 'none');
else
  set(p, 'EdgeColor', [0.33 0.33 0.33]);
end

% Setup material and lights
lighting gouraud
material dull
%camzoom(3.5);

% Default view
% [TODO] Associate this with the surface or as param
% This hack also works only for surfaces generated in our lab
if mean(surf.vertices(:,1))<0,
%    view(-90,0);
else,
%    view(90,0);
end;
%l1 = light('position',[1 0 1],'color','w','style','infinite');
%l2 = light('position',[-1 0 1],'color','w','style','infinite');
main_ah = gca;

% Show colorbar if it has activation colormap
if size(map,1)>3,
    ah = findobj('Tag','rave_colorbar');
    if ~isempty(ah);
	delete(ah);
    end
    szM = size(map2,1);
    %set(gcf,'units','normalized');
    %ah = axes('position',[0.85 0.3 0.025 0.4],'Tag','rave_colorbar');
    %image(permute(flipud(map2),[1 3 2]));
    %set(ah,'yaxislocation','right','xtick',[]);
    %set(ah,'ytick',[1 szM/2 szM],'yticklabel',{'+','0','-'});
    %set(ah,'Tag','rave_colorbar');
    %colorbar;
end;
%axes(main_ah);
