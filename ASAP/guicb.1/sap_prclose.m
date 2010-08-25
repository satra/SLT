function bclosed = sap_prclose;
% SAP_PRCLOSE 
%  SAP_PRCLOSE closes an opened A.S.A.P project

%   Satrajit Ghosh, SpeechLab, Boston University. (c)2001
%   $Revision: 3 $  $Date: 10/08/02 2:36p $

handles = guihandles(gcbf);

bclosed = 1;
if getappdata(handles.sap_mainfrm,'openflag'),
    if getappdata(handles.sap_mainfrm,'saveflag'),
        reply=questdlg('Save current project?', ...
            'A.S.A.P: Save project', ...
            'Yes','No','Cancel','Cancel');
        switch reply,
        case 'Yes',
            sap_prsave;
        case 'No',
        case 'Cancel',
            bclosed = 0;
            return;
        end;
    end;
    setappdata(handles.sap_mainfrm,'openflag',0);
    sap_clientmanager('deleteobj',[],[],handles,'crosshair');    
    sap_clientmanager('deleteobj',[],[],handles,'wksaxes');
    sap_clientmanager('deleteobj',[],[],handles,'cvimgs');
    setappdata(handles.sap_mainfrm,'clientdata',[]);
    setappdata(handles.sap_mainfrm,'autoset',0);
    set(handles.sap_autoset,'value',0);
    sap_savetimer('stop');
end;
