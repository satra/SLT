function [bChange,white_val,gray_val] = ...
    getInteractiveValues(braindatafile,brainmaskfile2,cortexfile);

fig = contourActor;
handles = guihandles(fig);

V = spm_vol(braindatafile);
braindata = spm_read_vols(V);
%load(braindatafile);
load(brainmaskfile2);
load(cortexfile);

set(handles.contourActor,'doublebuffer','on');
N = size(braindata,2);
imgnum = round(N/2);
setappdata(handles.contourActor,'imgnum',imgnum);

set(handles.imgsl,...
    'min',1,'max',N,...
    'value',imgnum,...
    'sliderstep',[1/(N-1) 10/(N-1)]);
set(handles.imgsltxt,'string',num2str(imgnum));
graytrans = uitransfer(fig,handles.gray_axs,[1 N],[0 1]);
whitetrans = uitransfer(fig,handles.white_axs,[1 N],[0 1]);
setdata(graytrans,'xlim',[1 N]);
setdata(whitetrans,'xlim',[1 N]);
if exist('gray_pts','var')
    setdata(graytrans,'points',gray_pts);
    if length(gray_pts)>2,
        setdata(graytrans,'ylim',[min(gray_pts(:,2)) max(gray_pts(:,2))]);    
    end;
else,
    setdata(graytrans,'Value',0);
end;
if exist('white_pts','var'),
    setdata(whitetrans,'points',white_pts);
    if length(white_pts)>2,
        setdata(whitetrans,'ylim',[min(white_pts(:,2)) max(white_pts(:,2))]);    
    end;
else,
    setdata(whitetrans,'Value',0);
end;

setappdata(handles.contourActor,'gtrans',graytrans);
setappdata(handles.contourActor,'wtrans',whitetrans);

gval = -1;
wval = -1;
val  = -1;
setappdata(handles.contourActor,'gval',gval);
setappdata(handles.contourActor,'wval',wval);
setappdata(handles.contourActor,'val',val);
setappdata(handles.curval,'string',['current val: [' num2str(val) ']']);


set(handles.grayvaltxt,'string',num2str(gval));
set(handles.wvaltxt,'string',num2str(wval));

imgfull = squeeze(braindata(:,imgnum,:))';
imgmask = double(squeeze((brainmask(:,imgnum,:)))').*imgfull;
setappdata(handles.contourActor,'imgmask',imgmask);
setappdata(handles.contourActor,'maxval',max(braindata(:).*double(brainmask(:))));

axes(handles.imgaxs);
set(handles.imgaxs,'nextplot','replacechildren');
image('Parent',handles.imgaxs,'Cdata',imgfull,'Cdatamapping','scaled');
axis(handles.imgaxs,'xy');
axis(handles.imgaxs,'image');
map = gray(64);
colormap(handles.imgaxs,map);

hold on;
contour(squeeze(cortexmask(:,imgnum,:))',[1 1],'r');
hold off;

% create a dummy axis over this image
dummyaxs = axes(...
    'Parent',handles.contourActor,...
    'position',get(handles.imgaxs,'position'),...
    'color','none',...
    'Xlim',get(handles.imgaxs,'Xlim'),...
    'Ylim',get(handles.imgaxs,'Ylim'),...
    'Ydir',get(handles.imgaxs,'Ydir'),...
    'Drawmode','fast',...
    'Xlimmode','manual',...
    'Ylimmode','manual',...
    'plotboxaspectratio',get(handles.imgaxs,'plotboxaspectratio'),...
    'dataaspectratio',get(handles.imgaxs,'dataaspectratio'),...
    'nextplot','replacechildren',...
    'Tag','dummyaxs');
set(dummyaxs,'Buttondownfcn','contourActorcb(''down'')');

setappdata(handles.contourActor,'braindata',braindata);
setappdata(handles.contourActor,'brainmask',brainmask);
setappdata(handles.contourActor,'cortexmask',cortexmask);
clear braindata brainmask cortexmask

uiwait(handles.contourActor);
bChange = getappdata(handles.contourActor,'bChange');
%gwif = getappdata(handles.contourActor,'wval');
%gray_val = getappdata(handles.contourActor,'gval');
white_val = [];
gray_val = [];

if bChange,
    maxval = getappdata(handles.contourActor,'maxval');
    gray_pts = getdata(graytrans,'points');
    gray_val = interp1(gray_pts(:,1),gray_pts(:,2),[1:N]')*maxval;
    white_pts = getdata(whitetrans,'points');
    white_val = interp1(white_pts(:,1),white_pts(:,2),[1:N]')*maxval;
    save(cortexfile,'gray_pts','white_pts','-APPEND');
end;

close(handles.contourActor);
