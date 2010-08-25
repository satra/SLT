function htrans = delete(htrans)
% DELETE Destructor for the uicontrol
%   The only parameter is the instance of the object to be deleted

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/@uitransfer/delete.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

if htrans.validui,
    if nargout==0,
        error('call syntax: object_name = delete(object_name);');
    end;
    delete(htrans.line);
    if htrans.controlaxs,
        delete(htrans.axs);
    end;
    if htrans.controlfig,
        delete(htrans.fig);
    end;
    htrans.validui = 0;
else,
    error('Invalid object handle');
end;