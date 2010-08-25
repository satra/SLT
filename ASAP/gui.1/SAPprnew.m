function varargout = SAPprnew(varargin)
% DETPRNEW Application M-file for DETprnew.fig
%    FIG = DETPRNEW launch DETprnew GUI.
%    SAPPRNEW('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 01-Feb-2001 13:54:15

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

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
function varargout = prnew_srcdir_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.prnew_srcdir.
data = guidata(gcbf);
data.fullname = get(data.prnew_srcdir,'String');
guidata(gcbf,data);


% --------------------------------------------------------------------
function varargout = prnew_srcbrowse_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.prnew_srcbrowse.
data = guidata(gcbf);
pdir = pwd;
cd(data.config.lastwd);
[filename,pathname] = uigetfile('*.img','Pick an Analyze Header file');
cd(pdir);
if isequal(filename,0)|isequal(pathname,0),
else,
    data.filename = filename;
    data.pathname = pathname;
    [pth,nm,ext] = fileparts(filename);
    data.fullname = [pathname filename];
    data.projname = nm;
    set(data.prnew_srcdir,'String',data.fullname);
    set(data.prnew_name,'String',data.projname);
    guidata(gcbf,data);
end;


% --------------------------------------------------------------------
function varargout = prnew_ok_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.prnew_ok.
data = guidata(gcbf);

if ~isempty(data) & isfield(data,'projname') & isfield(data,'fullname'),
    pdir = pwd;
    cd(data.pathname);
    [filename,pathname] = uiputfile([data.projname '.spt'],'Save Project');
    if isequal(filename,0)|isequal(pathname,0),
    else,
        data.convert = get(data.prnew_process,'value');
        data.projfile = filename;
        data.projpath = pathname;
        data.setflag  = 1;
        guidata(gcbf,data);
        uiresume(gcbf);
    end
    cd(pdir);
end;

% --------------------------------------------------------------------
function varargout = prnew_cancel_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.prnew_cancel.
data = guidata(gcbf);
data.setflag  = 0;
guidata(gcbf,data);
uiresume(gcbf);

% --------------------------------------------------------------------
function varargout = prnew_name_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.prnew_name.
data = guidata(gcbf);
data.projname = get(h,'String');
guidata(gcbf,data);


% --------------------------------------------------------------------
function varargout = prnew_process_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.prnew_process.
disp('prnew_process Callback not implemented yet.')