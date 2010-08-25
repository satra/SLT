function sap_status(handles,str,bFlash)
% SAP_STATUS Displays a message in the status text box
%   In addition to displaying a message, if it is an important message/warning/error
%   the third parameter can be set to 1 which will flash the message in a red background
%   to grab attention.

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/guicb.1/sap_status.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Setup globals
global DEBUG

set(handles.sap_status,'String',['- ' str]);
if nargin>2 & bFlash,
    set(handles.sap_status,'BackgroundColor',[1 0 0]);
    pause(1);
    set(handles.sap_status,'BackgroundColor',[0 0.15 0.15]);
end;
%refresh(handles.sap_mainfrm);