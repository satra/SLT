function varargout = SAPmainfrm(varargin)
% SAPMAINFRM Application M-file for SAPmainfrm.fig
%    FIG = SAPMAINFRM launch SAPmainfrm GUI.
%    SAPMAINFRM('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 09-Feb-2004 12:49:03

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/gui.1/SAPmainfrm.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

if nargin == 0  % LAUNCH GUI
    
    fig = openfig(mfilename,'reuse');
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    guidata(fig, handles);
    
    if nargout > 0
        varargout{1} = fig;
    end
    
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    %try
    [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    %catch
    %disp(lasterr);
    %end
    
end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.


% --------------------------------------------------------------------
function varargout = sap_preproc_Callback(h, eventdata, handles, varargin)
% Currently this misnamed function performs contour editing. Details to
% follow [TODO:???]
handles = guihandles(gcbf);
fdata = getappdata(handles.sap_mainfrm,'fdata');

if sap_autoseg(fdata.fullsrc,1),   
    otldata = getappdata(handles.sap_mainfrm,'otldata');
    slicemod = getappdata(handles.sap_mainfrm,'slicemod');
    
    % reset slicemodification state to 0
    slicemod(:) = 0;
    
    % load the original outlines
    % TODO: check if the pathname gets modified if the user is operating
    % on a different directory than original. If so, the user needs to be
    % notified about having the otl file in the same directory as the .spt
    % file
    try
        load(fdata.otlfile);
    catch
        msg = lasterr;
        sap_status(handles,['RESETOTL Load failed: ' msg],1);
        
        % Return without changing anything
        return;
    end
    offset = getappdata(handles.sap_mainfrm,'offset');
    % Replace the current data with the original data
    otldata = otl(offset(2):end);
    
    % Update the application store
    setappdata(handles.sap_mainfrm,'slicemod',slicemod);        
    setappdata(handles.sap_mainfrm,'otldata',otldata);
    
    % Set the project modified flag and update the title
    setappdata(handles.sap_mainfrm,'saveflag',1);
    sap_titlechange(handles.sap_mainfrm,1);
end;

% --------------------------------------------------------------------
function varargout = sap_segedit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_segedit.
handles = guihandles(gcbf);
curpos = getappdata(handles.sap_mainfrm,'curpos');
if curpos(4)~=2,
    sap_status(handles,'segM: Must be in coronal view',1);
    return;
end;
sap_clientmanager('modechange',[],[],handles,'segment');


% --------------------------------------------------------------------
function varargout = sap_sulciedit_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_sulciedit.
handles = guihandles(gcbf);
sap_clientmanager('modechange',[],[],handles,'sulci');


% --------------------------------------------------------------------
function varargout = sap_parcellate_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_parcellate.
handles = guihandles(gcbf);
curpos = getappdata(handles.sap_mainfrm,'curpos');
if curpos(4)~=2,
    sap_status(handles,'parcM: Must be in coronal view',1);
    return;
end;
sap_clientmanager('modechange',[],[],handles,'parc');


% --------------------------------------------------------------------
function varargout = sap_label_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_label.
handles = guihandles(gcbf);
curpos = getappdata(handles.sap_mainfrm,'curpos');
if curpos(4)~=2,
    sap_status(handles,'labelM: Must be in coronal view',1);
    return;
end;
sap_clientmanager('modechange',[],[],handles,'label');


% --------------------------------------------------------------------
function varargout = sap_view3d_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_view3d.
handles = guihandles(gcbf);
sap_clientmanager('modechange',[],[],handles,'view3d');
disp('sap_view3d Callback not implemented yet.')


% --------------------------------------------------------------------
function varargout = sap_browse_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_browse.
handles = guihandles(gcbf);
sap_clientmanager('modechange',[],[],handles,'browse');


% --------------------------------------------------------------------
function varargout = sap_slprog_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_slprog.
% Progress slider. Possibly not required
%disp('sap_slprog Callback not implemented yet.')


% --------------------------------------------------------------------
% NOTE: The comments for this callback applies to the following three callbacks
function varargout = sap_slcor_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_slcor.
% Coronal axis slider callback
handles = guihandles(gcbf);
curpos = getappdata(handles.sap_mainfrm,'curpos');
val = round(get(h,'Value'));
% Update only if position has changed
if (curpos(2) ~= val),
    curpos(2) = val;
    
    % update position values
    setappdata(handles.sap_mainfrm,'curpos',curpos);
    
    % restrict brightness scaling factor
    setappdata(handles.sap_mainfrm,'oldbval',1);
    
    % update the images
    sap_clientmanager('update',[],[],handles,'position',2,2);
    
    % check for autoset and update the main workspace figures
    if getappdata(handles.sap_mainfrm,'autoset'),
        sap_clientmanager('update',[],[],handles,'setpos');
    end
end;


% --------------------------------------------------------------------
function varargout = sap_slsag_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_slsag.
% See coronal update for details
handles = guihandles(gcbf);
curpos = getappdata(handles.sap_mainfrm,'curpos');
val = round(get(h,'Value'));
if (curpos(1) ~= val),
    curpos(1) = val;
    setappdata(handles.sap_mainfrm,'curpos',curpos);
    setappdata(handles.sap_mainfrm,'oldbval',1);
    sap_clientmanager('update',[],[],handles,'position',2,1);
    if getappdata(handles.sap_mainfrm,'autoset'),
        sap_clientmanager('update',[],[],handles,'setpos');
    end
end;


% --------------------------------------------------------------------
function varargout = sap_slaxi_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_slaxi.
% See coronal update for details
handles = guihandles(gcbf);
curpos = getappdata(handles.sap_mainfrm,'curpos');
val = round(get(h,'Value'));
if (curpos(3) ~= val),
    curpos(3) = val;
    setappdata(handles.sap_mainfrm,'curpos',curpos);
    setappdata(handles.sap_mainfrm,'oldbval',1);
    sap_clientmanager('update',[],[],handles,'position',2,3);
    if getappdata(handles.sap_mainfrm,'autoset'),
        sap_clientmanager('update',[],[],handles,'setpos');
    end;
end;


% --------------------------------------------------------------------
function varargout = sap_slnum_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_slnum.
% Change the number of miniwindows
sap_clientmanager('numchange',[],[],guihandles(gcbf));


% The following callbacks arise from the various viewing options. These are
% the little blue buttons on the top left of the screen. Again the comments 
% for this callback is going to be applicable to the following 4.

% --------------------------------------------------------------------
function varargout = sap_vwotl_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_vwotl.
handles = guihandles(gcbf);

% For certain items such as outlines, parcellation lines and regions,
% the view must be coronal. The following lines just ensures that is the
% case
curpos = getappdata(handles.sap_mainfrm,'curpos');
if curpos(4)~=2,
    sap_status(handles,'otlV: Must be in coronal view',1);
    return;
end;
% Get the current state of this particular view and ...
viewt = getappdata(handles.sap_mainfrm,'otlview');
% ... toggle it
viewt = mod(viewt+1,2);
% update the status in the data store.
setappdata(handles.sap_mainfrm,'otlview',viewt);

% Update the related displays to ensure removal or creation of new view
sap_clientmanager('refreshcl',[],[],handles);

% Change the color of the button to indicate that it has been pressed
if viewt,
    set(handles.sap_vwotl,'BackgroundColor',[0 0.57 0]);
else,
    set(handles.sap_vwotl,'BackgroundColor',[0 0 0.57]);
end;

% --------------------------------------------------------------------
function varargout = sap_vwsulc_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_vwsulc.
% See comments for sap_vwotl_Callback above
handles = guihandles(gcbf);
viewt = getappdata(handles.sap_mainfrm,'sulcview');
viewt = mod(viewt+1,2);
setappdata(handles.sap_mainfrm,'sulcview',viewt);
sap_clientmanager('refreshcl',[],[],handles);
if viewt,
    set(handles.sap_vwsulc,'BackgroundColor',[0 0.57 0]);
else,
    set(handles.sap_vwsulc,'BackgroundColor',[0 0 0.57]);
end;

% --------------------------------------------------------------------
function varargout = sap_vwnod_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_vwnod.
% See comments for sap_vwotl_Callback above
handles = guihandles(gcbf);
viewt = getappdata(handles.sap_mainfrm,'nodeview');
viewt = mod(viewt+1,2);
setappdata(handles.sap_mainfrm,'nodeview',viewt);
sap_clientmanager('refreshcl',[],[],handles);
if viewt,
    set(handles.sap_vwnod,'BackgroundColor',[0 0.57 0]);
else,
    set(handles.sap_vwnod,'BackgroundColor',[0 0 0.57]);
end;


% --------------------------------------------------------------------
function varargout = sap_vwparc_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_vwparc.
% See comments for sap_vwotl_Callback above
handles = guihandles(gcbf);
curpos = getappdata(handles.sap_mainfrm,'curpos');
if curpos(4)~=2,
    sap_status(handles,'parcV: Must be in coronal view',1);
    return;
end;
viewt = getappdata(handles.sap_mainfrm,'parcview');
viewt = mod(viewt+1,2);
setappdata(handles.sap_mainfrm,'parcview',viewt);
sap_clientmanager('refreshcl',[],[],handles);
if viewt,
    set(handles.sap_vwparc,'BackgroundColor',[0 0.57 0]);
else,
    set(handles.sap_vwparc,'BackgroundColor',[0 0 0.57]);
end;


% --------------------------------------------------------------------
function varargout = sap_vwreg_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_vwreg.
% See comments for sap_vwotl_Callback above
handles = guihandles(gcbf);
curpos = getappdata(handles.sap_mainfrm,'curpos');
if curpos(4)~=2,
    sap_status(handles,'regV: Must be in coronal view',1);
    return;
end;
viewt = getappdata(handles.sap_mainfrm,'labelview');
viewt = mod(viewt+1,2);
setappdata(handles.sap_mainfrm,'labelview',viewt);
sap_clientmanager('refreshcl',[],[],handles);
if viewt,
    set(handles.sap_vwreg,'BackgroundColor',[0 0.57 0]);
else,
    set(handles.sap_vwreg,'BackgroundColor',[0 0 0.57]);
end;


% --------------------------------------------------------------------
function varargout = sap_drpoly_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_drpoly.
handles = guihandles(gcbf);

% get the status of the drawmode and ...
drawmode = getappdata(handles.sap_mainfrm,'drawmode');
% ... toggle it
drawmode = mod(drawmode+1,2);
% update it in the data store
setappdata(handles.sap_mainfrm,'drawmode',drawmode);
% Different modes will query the status and perform different operations 
% depending on it

% Change the button display to indicate the mode is active.
if drawmode,
    set(handles.sap_drpoly,'BackgroundColor',[0 0.57 0]);
else,
    set(handles.sap_drpoly,'BackgroundColor',[0 0 0.57]);
end;


% --------------------------------------------------------------------
function varargout = sap_drfree_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_drfree.
disp('sap_drfree Callback not implemented yet.')


% --------------------------------------------------------------------
function varargout = sap_slbright_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_slbright.
sap_clientmanager('update',[],[],guihandles(gcbf),'brightness');


% --------------------------------------------------------------------
function varargout = sap_planesel_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_planesel.
handles = guihandles(gcbf);

% curpos(4) stores the value of the current view [sag,cor,axi]
% Determine if plane has been changed. If it has then update the views
% Modes which do not allow plane changes will automatically disable the
% GUI for it.
curpos = getappdata(handles.sap_mainfrm,'curpos');
val = round(get(h,'Value'));
if (curpos(4) ~= val),
    curpos(4) = val;
    setappdata(handles.sap_mainfrm,'curpos',curpos);
    sap_clientmanager('update',[],[],handles,'planechange',2);
end;


% --------------------------------------------------------------------
function varargout = sap_setcvpos_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_setcvpos.
handles = guihandles(gcbf);
% This button allows one to set the main workspace to reflect the displays
% in the miniwindows on the right.
sap_clientmanager('update',[],[],handles,'setpos');


% --------------------------------------------------------------------
function varargout = sap_autoset_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.sap_autoset
handles = guihandles(gcbf);
% get the current state of the autoset mode and ...
autosetmode = getappdata(handles.sap_mainfrm,'autoset');
% ... toggle it
autosetmode = mod(autosetmode+1,2);
% update the data store
setappdata(handles.sap_mainfrm,'autoset',autosetmode);
% Different actions will query this flag to determine whether or not to
% automatically update the main workspace views



% --- Executes on button press in sap_redolabel.
function sap_redolabel_Callback(hObject, eventdata, handles)
% hObject    handle to sap_redolabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sap_redolabel


% --- Executes on button press in sap_setnone.
function sap_setnone_Callback(hObject, eventdata, handles)
% hObject    handle to sap_setnone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sap_setnone


% --- Executes on button press in sap_set2label.
function sap_set2label_Callback(hObject, eventdata, handles)
% hObject    handle to sap_set2label (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sap_set2label


