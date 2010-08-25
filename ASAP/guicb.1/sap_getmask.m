function mask = sap_getmask(lines1,lines2,multf)
% SAP_GETMASK Manages all updatable clients on the GUI
%    SAP_CLIENTMANAGER initializes the client manager
%    SAP_CLIENTMANAGER('callback_name', ...) invoke the named callback.

%   Satrajit Ghosh, SpeechLab, Boston University. (c)2001
%   $Revision: 2 $  $Date: 10/08/02 2:36p $

mask = zeros(multf*256);
sz = size(mask);
for i=1:length(lines1),
    if ~isempty(lines1{i}),
        ptlist = [];
        ptlist = sap_interp(multf*lines1{i}.ptlist);
        ind = sub2ind(sz,ptlist(:,2),ptlist(:,1));    
        mask(ind) = 1;
    end;
end;
for i=1:length(lines2),
    if ~isempty(lines2{i}),
        ptlist = [];
        ptlist = sap_interp(multf*lines2{i}.ptlist);
        idx = find(ptlist(:)>multf*256);
        if isempty(idx)
            ind = sub2ind(sz,ptlist(:,2),ptlist(:,1));    
            mask(ind) = 1;
        end;
    end;
end;
%mask=mask(1:multf:end,1:multf:end);