vtkPolyDataMapper *skinMapper = vtkPolyDataMapper::New();
vtkActor *skin = vtkActor::New();
vtkRenderer *aRenderer = vtkRenderer::New();
vtkRenderWindow *renWin = vtkRenderWindow::New();
vtkRenderWindowInteractor *iren = vtkRenderWindowInteractor::New();

// do rendering stuff to get hold of final object
skinMapper->SetInput(surf);
skinMapper->ScalarVisibilityOff();

skin->SetMapper(skinMapper);

aRenderer->AddActor(skin);
aRenderer->SetBackground(1,1,1);

iren->SetRenderWindow(renWin);

renWin->AddRenderer(aRenderer);
renWin->SetSize(500,500);
renWin->Render();
    
// Start interactive rendering
iren->Start();

skinMapper->Delete();
skin->Delete();
aRenderer->Delete();
renWin->Delete();
iren->Delete();
