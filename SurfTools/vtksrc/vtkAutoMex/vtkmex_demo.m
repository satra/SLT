vtkstruct_demo01
vtkmex(vtkstruct);

vtkstruct_demo02  
vtkmex(vtkstruct);

vtkstruct_demo03  
vtkmex(vtkstruct);

vtkstruct_demo04  
vtkmex(vtkstruct);

FLAGS = {'-ID:\SOFTWARE\VTK\include','-LD:\SOFTWARE\VTK\lib','-lvtkCommon','-lvtkGraphics','-lvtkFiltering','-lvtkRendering'};
mex(FLAGS{:},'vtkReorient.cpp');
mex(FLAGS{:},'vtkIsoSurface.cpp');
mex(FLAGS{:},'vtkDecimate.cpp');
mex(FLAGS{:},'vtkOpenGL.cpp');

a = rand(50,50,50);
fv = vtkIsoSurface(double(a>0.8),int32(size(a)),0,0.5,0,0.95);
fv2 = vtkDecimate(double(fv.vertices),int32(fv.faces),1,0.99);
fv1 = vtkOpenGL(fv.vertices,int32(fv.faces));
