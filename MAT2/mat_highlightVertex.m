function mat_highlightVertex(sf,v)

surf = st_preprocess(sf);

nb = st_neighbors(surf,v);
for i=1:length(nb),
    nb = [nb; st_neighbors(surf,nb(i))];
end;

mycolors = zeros(length(surf.vertices),1);
mycolors(nb) = 1;

showVertexValue(sf,mycolors);

lighting phong
