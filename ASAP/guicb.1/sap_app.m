function sap_app(cmd,val)
% SAP_APP(cmd,val) 
%  SAP_APP creates, opens, closes and saves A.S.A.P projects
%  cmd: 'new','open','close','save','prefs','mru','exit'
%  val: cmd = 'mru',val=1,2

%   Satrajit Ghosh, SpeechLab, Boston University. (c)2001
%   $Revision: 2 $  $Date: 10/08/02 2:36p $

switch(cmd),
case 'new',
    sap_prnew;
case 'open',
    sap_propen;
case 'close',
    sap_prclose;
case 'save',
    sap_prsave;
case 'prefs',
    sap_prprefs;
case 'mru',
    sap_prmru(val);
case 'exit',
    sap_prexit;
otherwise,
    disp(['Unhandled command:' cmd]);
end;