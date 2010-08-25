function sap_prmru(val);
% SAP_PRMRU 
%  SAP_PRMRU updates mrus on the File menu

%   Satrajit Ghosh, SpeechLab, Boston University. (c)2001
%   $Revision: 2 $  $Date: 10/08/02 2:36p $

data = guihandles(gcbf);

switch val,
case 1,
    sap_propen(get(data.sap_mru1,'Label'));
case 2,
    sap_propen(get(data.sap_mru2,'Label'));
end;