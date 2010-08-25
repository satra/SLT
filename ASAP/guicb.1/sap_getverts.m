function ptlist = sap_getverts(lines1,lines2,multf)
% SAP_GETMASK Manages all updatable clients on the GUI
%    SAP_CLIENTMANAGER initializes the client manager
%    SAP_CLIENTMANAGER('callback_name', ...) invoke the named callback.

%   Satrajit Ghosh, SpeechLab, Boston University. (c)2001
%   $Revision: 2 $  $Date: 10/08/02 2:36p $

mask = zeros(multf*256);
sz = size(mask);
ptlist = [];
for i=1:length(lines1),
    if ~isempty(lines1{i}),
        ptlist = [ptlist;multf*lines1{i}.ptlist];
    end;
end;
for i=1:length(lines2),
    if ~isempty(lines2{i}),
        ptlist = [ptlist;multf*lines2{i}.ptlist];
    end;
end;
%mask=mask(1:multf:end,1:multf:end);