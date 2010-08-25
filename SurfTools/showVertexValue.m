function p = showVertexValue(surfStruct, cdata, varargin)
% Color the vertices with cdata. 
% ph = showVertexValue(surfStruct, cdata, [OPTION])
% OPTION = 1: (DEFAULT) show no markers, interpolate over triangle faces.  
% OPTION = 2: show and color markers, but not the triangle faces.

v = surfStruct.vertices;
f = surfStruct.faces;

%%% Axes
viewTM = view;
cla
axis off
axis vis3d
axis equal
view(viewTM);

switch nargin
 case 2,
  OPTION = 1;
 case 3,
  OPTION = varargin{1};
end

%%% Patch
V = size(v, 1);
cdata = cdata(:);
if size(cdata,1) ~= V
  fprintf('ERROR: length of %s differs from numVerts of %s!\n', ...
	  inputname(2), inputname(1));
  error('Exiting ...');
end
[cdataRGB, mincdata, maxcdata] = index2RGB(cdata);

%p = patch('Vertices', v, 'Faces', f,'FaceVertexCdata',cdata,...
%    'facecolor','interp','edgecolor','none','Cdatamapping','direct');

p = patch('Vertices', v, 'Faces', f, ...
	   'FaceVertexCData', cdataRGB, ...
	   'FaceLighting','gouraud');

if OPTION == 1
  set(p, 'FaceColor', 'interp', ...
	  'Marker', 'none');
else
  set(p, 'FaceColor', [0.5 0.5 0.5], ...
	  'Marker', 'o', ...
	  'MarkerFaceColor', 'flat');
end

if maxcdata - mincdata > sqrt(eps)
  set(gca, 'CLim', [mincdata maxcdata]);
else
  addeps = 0.01*abs(maxcdata);
  if addeps == 0
      addeps = eps;
  end
  set(gca, 'CLim', [mincdata-addeps maxcdata+addeps]);
end

if V > 2500
  set(p, 'EdgeColor', 'none');
else
  set(p, 'EdgeColor', [0.33 0.33 0.33]);
end

lighting gouraud
material dull
