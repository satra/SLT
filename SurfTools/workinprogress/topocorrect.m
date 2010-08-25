%load brainsurf fv3;
%surfstruct = preprocess(fv3);

load freesurf;
[mc, gc] = curvature(surfstruct);
mc = abscurvature(surfstruct,mc);
cla;
showVertexValue(surfstruct, mc);
drawnow;
inflatedSurf = motionByMeanCurv(surfstruct, 2, 400, 1, 0, 0, 1);
cla;
showVertexValue(inflatedSurf, mc);
drawnow;

testsurf = inflatedSurf;
testsurf = sphereSurf(testsurf,mc);
