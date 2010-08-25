function sap_savetimer(varargin)
% SAP_SAVETIMER Starts a timer to autosave every 5 minutes

try
switch varargin{1},
    case 'init',
        t = timer('Tag','savetimer',...
            'ExecutionMode','fixedDelay',...
            'TimerFcn','sap_savetimer(''fire'');',...
            'Period', 10*60,...
            'Userdata',varargin{2});
        start(t);
    case 'fire',
        t = timerfind('Tag','savetimer');
        handles = get(t,'Userdata');
        sap_prsave(1,handles.sap_mainfrm);
        sap_status(handles,'Autosaved');        
    case 'stop',
        t = timerfind('Tag','savetimer');
        stop(t);
        delete(t);
    otherwise,
end;
catch
    disp('Timer setting failed');
end;