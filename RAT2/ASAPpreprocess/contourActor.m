function varargout = contourActor(varargin)
% CONTOURACTOR Application M-file for contourActor.fig
%    FIG = CONTOURACTOR launch contourActor GUI.
%    CONTOURACTOR('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 18-Nov-2001 19:23:03

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
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
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
function varargout = imgsl_Callback(h, eventdata, handles, varargin)
val = round(get(h,'value'));
handles = guihandles(handles.contourActor);

imgnum = getappdata(handles.contourActor,'imgnum');
if val ~= imgnum,
    imgnum = val;
    setappdata(handles.contourActor,'imgnum',imgnum);
    set(handles.imgsltxt,'string',num2str(imgnum));
    
    braindata = getappdata(handles.contourActor,'braindata');
    brainmask = getappdata(handles.contourActor,'brainmask');
    cortexmask = getappdata(handles.contourActor,'cortexmask');
    
    imgfull = squeeze(braindata(:,imgnum,:))';
    imgmask = double(squeeze((brainmask(:,imgnum,:)))').*imgfull;
    setappdata(handles.contourActor,'imgmask',imgmask);
    
    axes(handles.imgaxs);
    set(handles.imgaxs,'nextplot','replacechildren');
    image('Parent',handles.imgaxs,'Cdata',imgfull,'Cdatamapping','scaled');
    axis(handles.imgaxs,'xy');
    axis(handles.imgaxs,'image');
    
    hold on;
    contour(squeeze(cortexmask(:,imgnum,:))',[1 1],'r');
    hold off;
    axes(handles.dummyaxs);
    cla;
end;

% --------------------------------------------------------------------
function varargout = whitevalbtn_Callback(h, eventdata, handles, varargin)
val = getappdata(handles.contourActor,'val');

wtrans = getappdata(handles.contourActor,'wtrans');
maxval = getappdata(handles.contourActor,'maxval');
imgnum = getappdata(handles.contourActor,'imgnum');
modifytransf(val,wtrans,maxval,imgnum);

setappdata(handles.contourActor,'wval',val);
set(handles.wvaltxt,'string',num2str(val));

% --------------------------------------------------------------------
function varargout = grayvalbtn_Callback(h, eventdata, handles, varargin)
val = getappdata(handles.contourActor,'val');

gtrans = getappdata(handles.contourActor,'gtrans');
maxval = getappdata(handles.contourActor,'maxval');
imgnum = getappdata(handles.contourActor,'imgnum');
modifytransf(val,gtrans,maxval,imgnum);

setappdata(handles.contourActor,'gval',val);
set(handles.grayvaltxt,'string',num2str(val));

% --------------------------------------------------------------------
function varargout = donebtn_Callback(h, eventdata, handles, varargin)
setappdata(handles.contourActor,'bChange',1);
uiresume(handles.contourActor);

% --------------------------------------------------------------------
function varargout = cancelbtn_Callback(h, eventdata, handles, varargin)
setappdata(handles.contourActor,'bChange',0);
uiresume(handles.contourActor);


% --------------------------------------------------------------------
function varargout = wshowbtn_Callback(h, eventdata, handles, varargin)
handles = guihandles(handles.contourActor);
% val = getappdata(handles.contourActor,'wval');
% if val ~= -1,
%     imgmask = getappdata(handles.contourActor,'imgmask');
%     axes(handles.dummyaxs);
%     [c,h] = contour(imgmask,[val val],'b');
%     set(h,'hittest','off');
% end;
wtrans = getappdata(handles.contourActor,'wtrans');
maxval = getappdata(handles.contourActor,'maxval');
imgnum = getappdata(handles.contourActor,'imgnum');
val = transval(wtrans,maxval,imgnum);
if isempty(val),
    return;
end;
imgmask = getappdata(handles.contourActor,'imgmask');
axes(handles.dummyaxs);
[c,h] = contour(imgmask,[val val],'b');
set(h,'hittest','off');
setappdata(handles.contourActor,'wval',val);
set(handles.wvaltxt,'string',num2str(val));

% --------------------------------------------------------------------
function varargout = cshowbtn_Callback(h, eventdata, handles, varargin)
handles = guihandles(handles.contourActor);
val = getappdata(handles.contourActor,'val');
if val ~= -1,
    imgmask = getappdata(handles.contourActor,'imgmask');
    axes(handles.dummyaxs);
    [c,h] = contour(imgmask,[val val],'b');
    set(h,'hittest','off');
end;
% --------------------------------------------------------------------
function varargout = gshowbtn_Callback(h, eventdata, handles, varargin)
handles = guihandles(handles.contourActor);
% val = getappdata(handles.contourActor,'gval');
% if val ~= -1,
%     imgmask = getappdata(handles.contourActor,'imgmask');
%     axes(handles.dummyaxs);
%     [c,h] = contour(imgmask,[val val],'b');
%     set(h,'hittest','off');
% end;
gtrans = getappdata(handles.contourActor,'gtrans');
maxval = getappdata(handles.contourActor,'maxval');
imgnum = getappdata(handles.contourActor,'imgnum');
val = transval(gtrans,maxval,imgnum);
if isempty(val),
    return;
end;
imgmask = getappdata(handles.contourActor,'imgmask');
axes(handles.dummyaxs);
[c,h] = contour(imgmask,[val val],'b');
set(h,'hittest','off');
setappdata(handles.contourActor,'wval',val);
set(handles.wvaltxt,'string',num2str(val));


function modifytransf(val,htrans,maxval,imgnum);

pts = getdata(htrans,'points');
if all(pts(:,2)==0),
    pts(:,2) = val/maxval;
    setdata(htrans,'points',pts);
    setdata(htrans,'ylim',pts(1,2)+[-0.2 0.2]);
else,
    idx = find(pts(:,1)==imgnum);
    if isempty(idx),
        pts = [pts;imgnum,val/maxval];
        pts = sortrows(pts);
    else,
        pts(idx,2) == val/maxval;
    end
end;
setdata(htrans,'ylim',[min(pts(:,2)) max(pts(:,2))]);
setdata(htrans,'points',pts);

function val = transval(htrans,maxval,imgnum);
pts = getdata(htrans,'points');
if all(pts(:,2)==0),
    val = [];
else,
    idx = find(pts(:,1)==imgnum);
    if isempty(idx),
        val = interp1(pts(:,1),pts(:,2),imgnum)*maxval;
    else,
        val = pts(idx,2)*maxval;
    end
end;
