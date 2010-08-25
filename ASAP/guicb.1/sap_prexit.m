function sap_prexit;
% SAP_PREXIT
%  SAP_PREXIT exits A.S.A.P

%   Satrajit Ghosh, SpeechLab, Boston University. (c)2001
%   $Revision: 2 $  $Date: 10/08/02 2:36p $

handles = guihandles(gcbf);

if getappdata(handles.sap_mainfrm,'openflag'),
    if ~sap_prclose,
        disp('not closing');
        return;
    end;
end;
close;