function varargout = sap_clientmanager(varargin)
% SAP_CLIENTMANAGER Manages all updatable clients on the GUI
%   This is probably one of the single most important functions in this package.It
%   handles everthing starting from routing callbacks to the appropriate routines,
%   dealing with differences when switching from one mode to another, storing handles
%   of drawn objects, etc.,.
%    SAP_CLIENTMANAGER initializes the client manager
%    SAP_CLIENTMANAGER('callback_name', ...) invokes the named callback.
%   The various types of 'callback_name' types are:
%        'addclient'
%        'deleteobj'
%        'update'
%        'numchange'
%        'modechange'
%        'modestart'
%        'modeend'
%        'buttondowncb'
%        'refreshcl'
%        'refresh_views'
%   Each of them carry their own information along with their implementation

% TODO: There are still various changes that can/should be made to this function
% - add critical section access to clientdata, such that it does not get changed
%   while somebody else is accessing it
% -   

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/guicb.1/sap_clientmanager.m 5     10/08/02 2:36p Satra $

% $NoKeywords: $

% Setup globals
global DEBUG

if nargin == 0  % INITIALIZE MANAGER
    % Currently no intialization required    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    if DEBUG,
        [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    else,
        %try
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
            %catch
            %msg = lasterr
            %sap_status(handles,['Clientmanager failure: ' msg],1);
            
            % Return on error
            %return;
            %end
    end
end

% --------------------------------------------------------------------
function varargout = addclient(h, eventdata, handles, varargin)
% ADDCLIENT_CB Adds matlab drawable graphic handles to a structure called
%   clientdata, which can be later used for accessing these handles
%   clientdata fields:
%       type    : 1 - workspace axes
%                 2 - cardinal view axes
%          clients: subfield contains axis handle and image handle
%       seghandles : handles to objects drawn in segment edit mode
%       sulchandles: handles to objects drawn in sulci edit mode
%       parchandles: handles to objects drawn in parcellation mode
%       reghandles : handles to objects drawn in labelling mode

% which client wants handles to be stored 
cltype = varargin{1};

switch cltype,
case 'wksaxis', % Workspace axes [left area of program]
    imh = varargin{2};      % image handle
    ctnum = varargin{3};    % 1<=client number<=total number of displayed axes
    
    % get clientdata from application store
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    
    % These are the important data: 
    clientdata.type(1).clients(ctnum,1) = h;    % axis handle
    clientdata.type(1).clients(ctnum,2) = imh;  % image handle
    
    % Client id generated but currently not used
    cuid = sap_createuid;   % generate a client ID
    clientdata.type(1).clients(ctnum,3) = cuid;
    
    % save clientdata to the application store
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
    
    % return client id as result
    varargout{1} = cuid;
    
case 'cvaxis',  % Cardinal view axes [right column of program]
    imh = varargin{2};      % image handle
    ctnum = varargin{3};    % 1<=client number<=3
    
    % get clientdata from application store
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');

    % These are the important data: 
    clientdata.type(2).clients(ctnum,1) = h;    % axis handle
    clientdata.type(2).clients(ctnum,2) = imh;  % image handle
    
    % Client id generated but currently not used
    cuid = sap_createuid;
    clientdata.type(2).clients(ctnum,3) = cuid;

    % save clientdata to the application store
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);

    % return client id as result
    varargout{1} = cuid;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The following clients store objects that are drawn on the image in the %
    % various modes, which are either meant for display or editing.          %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'segclient',   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Handles to objects drawn in Segment Edit mode %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % the second variable argument is the axis handle
    axh = varargin{2};
    
    % Find client number by looking up axis handle in clientdata
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    ctnum = find(clientdata.type(1).clients(:,1)== axh);
    
    % Store the segment handles for that slice
    clientdata.seghandles{ctnum} = h;
    
    % update the application store with the new data
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
case 'sulcclient',
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Handles to objects drawn in Sulci Edit mode %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % the second variable argument is the axis handle
    axh = varargin{2};

    % Find client number by looking up axis handle in clientdata
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    ctnum = find(clientdata.type(1).clients(:,1)== axh);

    % Store the sulci handles for that slice
    clientdata.sulchandles{ctnum} = h;

    % update the application store with the new data
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
case 'parcclient',
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Handles to objects drawn in Parcellation mode %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % the second variable argument is the axis handle
    axh = varargin{2};

    % Find client number by looking up axis handle in clientdata
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    ctnum = find(clientdata.type(1).clients(:,1)== axh);

    % Store the parcellation handles for that slice
    clientdata.parchandles{ctnum} = h;

    % update the application store with the new data
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
case 'regclient',
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Handles to objects drawn in Parcellation mode %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % the second variable argument is the axis handle
    axh = varargin{2};

    % Find client number by looking up axis handle in clientdata
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    ctnum = find(clientdata.type(1).clients(:,1)== axh);

    % Store the region handles for that slice
    clientdata.reghandles{ctnum} = h;

    % update the application store with the new data
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
otherwise,
    sap_status(handles,['Unknown client: ',cltype],1);
end;

% --------------------------------------------------------------------
function varargout = deleteobj(h,eventdata,handles,varargin)
% DELETEOBJ_CB Deletes handles from the clientdata structure that are no 
%   longer needed
%   deltype can be:
%       'wksaxes'       : workspace axes and their contents
%       'cvimgs'        : cardinal view axes and their contents
%       'crosshair'     : just the crosshair [TODO: go figure]
%       'seghandles'    : segment mode handles from all or a particular axis
%       'sulchandles'   : sulci mode handles from all or a particular axis
%       'parchandles'   : parc mode handles from all or a particular axis
%       'reghandles'    : label mode handles from all or a particular axis
%       'curline'       : calls the mode specific delete function for a particular
%                         selected line
%       varargin{2} is an axis handle for those types that use it

% which type of handles to be delete 
deltype = varargin{1};

switch(deltype),
case 'wksaxes',
    % get client data
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    % delete appropriate field
    delete(clientdata.type(1).clients(:,1));
    clientdata.type(1).clients = [];
    % store it back
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
case 'cvimgs',
    % get client data
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    % delete appropriate field
    delete(clientdata.type(2).clients(:,2));
    clientdata.type(2).clients = [];
    % store it back
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
case 'crosshair',
    % get client data
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    % determine if there is a field called pointhdl and delete it
    if isfield(clientdata,'pointhdl'),
        if ~isempty(clientdata.pointhdl),
            delete(clientdata.pointhdl);
            clientdata.pointhdl = [];
        end;
    end;
    % store it back
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
case 'seghandles',
    % get client data
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    % do nothing if there are no seghandles
    if ~isfield(clientdata,'seghandles') | isempty(clientdata.seghandles),
        return;
    end;
    % if an extra argument has been passed in, delete all handles belonging
    % to the specific axis
    if nargin == 5,
        axh = varargin{2};  % axis handle
        % get axis index from axis handle
        ctnum = find(clientdata.type(1).clients(:,1)== axh);
        % delete if not empty
        if ctnum<=length(clientdata.seghandles) & ~isempty([clientdata.seghandles{ctnum}]),
            delete([clientdata.seghandles{ctnum}]);
            clientdata.seghandles{ctnum} = [];
        end;
    else,
        % delete all segment mode handles
        if ~isempty([clientdata.seghandles{:}]),
            delete([clientdata.seghandles{:}]);
            clientdata.seghandles = {};
        end;
    end;
    % store it back
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
case 'sulchandles',
    % get client data
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    % do nothing if empty
    if ~isfield(clientdata,'sulchandles') | isempty(clientdata.sulchandles),
        return;
    end;
    % if an extra argument has been passed in, delete all handles belonging
    % to the specific axis
    if nargin == 5,
        axh = varargin{2};  % axis handle
        % get axis index from axis handle
        ctnum = find(clientdata.type(1).clients(:,1)== axh);
        % delete if not empty
        if ctnum<=length(clientdata.sulchandles) & ~isempty([clientdata.sulchandles{ctnum}]),
            delete([clientdata.sulchandles{ctnum}]);
            clientdata.sulchandles{ctnum} = [];
        end;
    else,
        % delete all sulci mode handles
        if ~isempty([clientdata.sulchandles{:}]),
            delete([clientdata.sulchandles{:}]);
            clientdata.sulchandles = {};
        end;
    end;
    % store it back
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
case 'parchandles',
    % get client data
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    % do nothing if empty
    if ~isfield(clientdata,'parchandles') | isempty(clientdata.parchandles),
        return;
    end;
    % if an extra argument has been passed in, delete all handles belonging
    % to the specific axis
    if nargin == 5,
        axh = varargin{2};  % axis handle
        % get axis index from axis handle
        ctnum = find(clientdata.type(1).clients(:,1)== axh);
        % delete if not empty
        if ctnum<=length(clientdata.parchandles) & ~isempty([clientdata.parchandles{ctnum}]),
            delete([clientdata.parchandles{ctnum}]);
            clientdata.parchandles{ctnum} = [];
        end;
    else,
        % delete all parc mode handles
        if ~isempty([clientdata.parchandles{:}]),
            delete([clientdata.parchandles{:}]);
            clientdata.parchandles = {};
        end;
    end;
    % store it back
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
case 'reghandles',
    % get client data
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    % do nothing if empty
    if ~isfield(clientdata,'reghandles') | isempty(clientdata.reghandles),
        return;
    end;
    % if an extra argument has been passed in, delete all handles belonging
    % to the specific axis    
    if nargin == 5,
        axh = varargin{2}; % axis handle
        % get axis index from axis handle
        ctnum = find(clientdata.type(1).clients(:,1)== axh);
        % delete if not empty
        if ctnum<=length(clientdata.reghandles) & ~isempty([clientdata.reghandles{ctnum}]),
            delete([clientdata.reghandles{ctnum}]);
            clientdata.reghandles{ctnum} = [];
        end;
    else,
        % delete all label mode handles
        if ~isempty([clientdata.reghandles{:}]),
            delete([clientdata.reghandles{:}]);
            clientdata.reghandles = {};
        end;
    end;
    % store it back
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
case 'curline',
    % This option is selected when the user clicks on a line
    % and chooses to delete it. Since each mode has its own
    % structure for drawn data, the mode's callback is called
    % to delete the line
    % clientdata.curlinedata is set when an editable line is 
    % left clicked on [selline_cb later in this file]
    switch getappdata(handles.sap_mainfrm,'oldmode'),
    case 'segment',
        clientdata = getappdata(handles.sap_mainfrm,'clientdata');
        udata = clientdata.curlinedata;
        clientdata.curlinedata = [];
        setappdata(handles.sap_mainfrm,'clientdata',clientdata);
        if ~isempty(udata),
            sap_segmentcb(udata.axh,eventdata,handles,'delline',udata.slnum,udata.idx);
        end;
    case 'sulci',
        clientdata = getappdata(handles.sap_mainfrm,'clientdata');
        udata = clientdata.curlinedata;
        clientdata.curlinedata = [];
        setappdata(handles.sap_mainfrm,'clientdata',clientdata);
        if ~isempty(udata),
            sap_sulcicb(udata.axh,eventdata,handles,'delline',udata.sulcnum,udata.idx);
        end;
    case 'parc',
        clientdata = getappdata(handles.sap_mainfrm,'clientdata');
        udata = clientdata.curlinedata;
        clientdata.curlinedata = [];
        setappdata(handles.sap_mainfrm,'clientdata',clientdata);
        if ~isempty(udata),
            sap_parccb(udata.axh,eventdata,handles,'delline',udata.slnum,udata.idx);
        end;
    end;
end;

% --------------------------------------------------------------------
function varargout = update(h, eventdata, handles, varargin)
% UPDATE_CB Updates various aspects of the workspace
%   varargin{1} determines the update type
%   varargin{2:end} are parameters which are passed directly to the updating function
%       position    :   updates the images in the workspace/cardinal views axes
%       brightness  :   changes the brightness of the images
%       planechange :   changes between cor/sag/axi planes
%       setpos      :   updates the workspace images to correspond to position
%                       in the cardinal views axes
updtype = varargin{1};
switch updtype,
case 'position',
    sap_posupdate(handles,varargin{2:end});
case 'brightness',
    sap_brightupdate(handles,varargin{2:end});
    sap_clientmanager('refreshcl',[],[],handles);
case 'planechange',
    % For this and the next function oldbval needs to be set to 1 to ensure
    % that the same brightness level is maintained
    setappdata(handles.sap_mainfrm,'oldbval',1);
    sap_clientmanager('update',[],[],handles,'position',1,[],1);
    sap_clientmanager('refreshcl',[],[],handles);
case 'setpos',
    setappdata(handles.sap_mainfrm,'oldbval',1);
    sap_clientmanager('update',[],[],handles,'position',1); %TODO used to be: ,1,3);
    sap_clientmanager('refreshcl',[],[],handles);
case 'otl',
case 'sulci',
case 'nodes',
case 'parc',
case 'regions',
otherwise,
end;


% --------------------------------------------------------------------
function varargout = numchange(h, eventdata, handles, varargin)
sap_clientmanager('deleteobj',[],[],handles,'crosshair');
sap_clientmanager('deleteobj',[],[],handles,'wksaxes');

% TODO: do other necesssary deletions

% Create new axes
sap_createwksimages(handles);
setappdata(handles.sap_mainfrm,'oldbval',1);
setappdata(handles.sap_mainfrm,'drawmode',0);
clientdata = getappdata(handles.sap_mainfrm,'clientdata');
clientdata.pointhdl = [];
clientdata.seghandles = {};
clientdata.sulchandles= {};
clientdata.parchandles = {};
clientdata.reghandles = {};
setappdata(handles.sap_mainfrm,'clientdata',clientdata);

sap_clientmanager('update',[],[],handles,'position',1,[],1);
sap_clientmanager('refreshcl',[],[],handles);


% --------------------------------------------------------------------
function varargout = modechange(h,eventdata,handles,varargin)
newmode = varargin{1};
oldmode = getappdata(handles.sap_mainfrm,'oldmode');
if strcmp(oldmode,newmode),
    return;
end;
sap_clientmanager('deleteobj',[],[],handles,'crosshair');
sap_clientmanager('modeend',[],[],handles,oldmode);
sap_clientmanager('modestart',[],[],handles,newmode);
setappdata(handles.sap_mainfrm,'oldmode',newmode);
sap_clientmanager('refreshcl',[],[],handles);


% --------------------------------------------------------------------
function varargout = modestart(h,eventdata,handles,varargin)
newmode = varargin{1};
switch newmode,
case 'segment',
    set(handles.sap_vwotl,'Enable','off');
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    set(clientdata.type(1).clients(:,1),'UIContextMenu',handles.sap_segmenu);
    set(handles.sap_planesel,'value',2);
    curpos = getappdata(handles.sap_mainfrm,'curpos');
    curpos(4) = 2;
    setappdata(handles.sap_mainfrm,'curpos',curpos);
    setappdata(handles.sap_mainfrm,'oldbval',1);
    sap_clientmanager('update',[],[],handles,'position',1);
    set(handles.sap_planesel,'Enable','off');
    set(handles.sap_segedit,'BackgroundColor',[0 0 0.5]);
    %    sap_segmentcb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1));
case 'sulci',
    set(handles.sap_vwsulc,'Enable','off');
    set(handles.sap_vwnod,'Enable','off');
    set(handles.sap_showpos,'Checked','on');
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    set(clientdata.type(1).clients(:,1),'UIContextMenu',handles.sap_sulcmenu);
    set(handles.sap_sulciedit,'BackgroundColor',[0 0 0.5]);
    %    sap_sulcicb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1));
case 'parc',
    set(handles.sap_vwparc,'Enable','off');
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    set(clientdata.type(1).clients(:,1),'UIContextMenu',[]);
    curpos = getappdata(handles.sap_mainfrm,'curpos');
    curpos(4) = 2;
    setappdata(handles.sap_mainfrm,'curpos',curpos);
    set(handles.sap_planesel,'value',2);
    setappdata(handles.sap_mainfrm,'oldbval',1);
    sap_clientmanager('update',[],[],handles,'position',1);
    set(handles.sap_planesel,'Enable','off');
    setappdata(handles.sap_mainfrm,'otlview',1);
    set(handles.sap_parcellate,'BackgroundColor',[0 0 0.5]);
case 'label',
    set(handles.sap_vwreg,'Enable','off');
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    set(clientdata.type(1).clients(:,1),'UIContextMenu',[]);
    curpos = getappdata(handles.sap_mainfrm,'curpos');
    curpos(4) = 2;
    setappdata(handles.sap_mainfrm,'curpos',curpos);
    set(handles.sap_planesel,'value',2);
    setappdata(handles.sap_mainfrm,'oldbval',1);
    sap_clientmanager('update',[],[],handles,'position',1);
    set(handles.sap_planesel,'Enable','off');
    sap_labelcb(h,eventdata,handles,'createregions');
    set(handles.sap_label,'BackgroundColor',[0 0 0.5]);
case 'view3d',
case 'browse',
    set(handles.sap_drpoly,'Enable','off');
%    set(handles.sap_drfree,'Enable','off');
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    set(clientdata.type(1).clients(:,1),'UIContextMenu',handles.sap_browsemenu);
    set(handles.sap_showpos,'Checked','on');
    sap_clientmanager('update',[],[],handles,'position',0);
otherwise,
end;


% --------------------------------------------------------------------
function varargout = modeend(h,eventdata,handles,varargin)
oldmode = varargin{1};
switch oldmode,
case 'segment',
    set(handles.sap_vwotl,'Enable','on');
    set(handles.sap_planesel,'Enable','on');
    sap_clientmanager('deleteobj',[],[],handles,'seghandles');
    set(handles.sap_segedit,'BackgroundColor',[0 0.5 0]);
case 'sulci',
    set(handles.sap_vwsulc,'Enable','on');
    set(handles.sap_vwnod,'Enable','on');
    set(handles.sap_showpos,'checked','off');
    sap_clientmanager('deleteobj',[],[],handles,'sulchandles');    
    set(handles.sap_sulciedit,'BackgroundColor',[0 0.5 0]);
case 'parc',
    set(handles.sap_vwparc,'Enable','on');
    set(handles.sap_planesel,'Enable','on');
    sap_clientmanager('deleteobj',[],[],handles,'parchandles');    
    setappdata(handles.sap_mainfrm,'otlview',0);
    set(handles.sap_parcellate,'BackgroundColor',[0 0.5 0]);
case 'label',
    set(handles.sap_vwreg,'Enable','on');
    set(handles.sap_planesel,'Enable','on');
    sap_clientmanager('deleteobj',[],[],handles,'reghandles');
    set(handles.sap_label,'BackgroundColor',[0 0.5 0]);
case 'view3d',
case 'browse',
    set(handles.sap_drpoly,'Enable','on');
%    set(handles.sap_drfree,'Enable','on');
    set(handles.sap_showpos,'checked','off');
    sap_clientmanager('update',[],[],handles,'position',0);
otherwise,
end;


% --------------------------------------------------------------------
function varargout = buttondowncb(h,eventdata,handles,varargin)
modetype = getappdata(handles.sap_mainfrm,'oldmode');
newmodetype = modetype;
if nargin == 4 & strcmp(varargin{1},'linesel'),
    newmodetype = 'linesel';
end;
switch newmodetype,
case 'browse',
    if strcmp(get(gcbf,'Selectiontype'),'normal'),
        sap_browsecb(h,eventdata,handles,'btndown');
    end;
case 'segment',
    if strcmp(get(gcbf,'Selectiontype'),'normal'),
        sap_segmentcb(h,eventdata,handles,'btndown');
    end;
case 'sulci',
    if strcmp(get(gcbf,'Selectiontype'),'normal'),
        sap_sulcicb(h,eventdata,handles,'btndown');
    end;
case 'parc',
    if strcmp(get(gcbf,'Selectiontype'),'normal'),
        sap_parccb(h,eventdata,handles,'btndown');
    end;
case 'label',
    if strcmp(get(gcbf,'Selectiontype'),'normal'),
        sap_labelcb(h,eventdata,handles,'btndown');
    end;
case 'linesel',
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    clientdata.curlinedata = [];
    clientdata.curlinedata = get(h,'userdata');
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);    
    if strcmp(modetype,'label'),
        if strcmp(get(gcbf,'Selectiontype'),'normal'),
            sap_labelcb(clientdata.curlinedata.axh,eventdata,handles,'btndown');
        end;
    end
end;


% --------------------------------------------------------------------
function refreshcl(h,eventdata,handles,varargin)
bCOR = refresh_views(h,eventdata,handles,varargin);
clientdata = getappdata(handles.sap_mainfrm,'clientdata');
switch getappdata(handles.sap_mainfrm,'oldmode'),
case 'browse',
    sap_posupdate(handles,0);
case 'segment',
    set(clientdata.type(1).clients(:,1),'UIContextMenu',handles.sap_segmenu);
    sap_segmentcb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1));
    bCOR = 1;
case 'sulci',
    set(clientdata.type(1).clients(:,1),'UIContextMenu',handles.sap_sulcmenu);
    sap_sulcicb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1));
case 'parc',
    set(clientdata.type(1).clients(:,1),'UIContextMenu',handles.sap_parcmenu);
    sap_parccb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1));
    bCOR = 1;
case 'label',
    set(clientdata.type(1).clients(:,1),'UIContextMenu',[]);
    sap_labelcb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1));
    bCOR = 1;
end;
if bCOR,
    set(handles.sap_planesel,'Enable','off');
else,
    set(handles.sap_planesel,'Enable','on');
end;
refresh(handles.sap_mainfrm);


% --------------------------------------------------------------------
function bCOR = refresh_views(h,eventdata,handles,varargin)
clientdata = getappdata(handles.sap_mainfrm,'clientdata');
bCOR = 0;
if getappdata(handles.sap_mainfrm,'labelview'),
    sap_labelcb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1),1);
    bCOR = 1;
else,
    sap_clientmanager('deleteobj',[],[],handles,'reghandles');
end;
if getappdata(handles.sap_mainfrm,'otlview'),
    sap_segmentcb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1),1);
    bCOR = 1;
else,
    sap_clientmanager('deleteobj',[],[],handles,'seghandles');
end;

if getappdata(handles.sap_mainfrm,'sulcview'),
    sap_sulcicb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1),1);
else,
    sap_clientmanager('deleteobj',[],[],handles,'sulchandles');
end;
if getappdata(handles.sap_mainfrm,'parcview'),
    sap_parccb(h,eventdata,handles,'refresh',clientdata.type(1).clients(:,1),1);
    bCOR = 1;
else,
    sap_clientmanager('deleteobj',[],[],handles,'parchandles');
end;