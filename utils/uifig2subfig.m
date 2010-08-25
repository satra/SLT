function uifig2subfig(varargin)
% FUNCTION UI_FIG2SUBFIG copies open figure windows into subplots
% of 1 or more figures
%
% UI_FIG2SUBFIG(FIG_HANDLES) copies only the figure handles
% specified.
%
% UI_FIG2SUBFIG(...,N) copies the figures into N figure windows,
% with the number of subfigures per window defined as
% length(FIG_HANDLES)/N. [Default N=1]

% Satrajit Ghosh, 14Oct2004

if nargin<1 | isempty(varargin{1})
    figure_handles = get(0,'children');
    figure_handles = sort(figure_handles);
else,
    figure_handles = varargin{1};
end
Nin = length(figure_handles);
Nopenfigures = max(get(0,'children'));

if nargin<2 | isempty(varargin{2}),
    Nout = 1;
else
    Nout = varargin{2};
end

if nargin<3,
    nrows = [];ncols = [];
else
    nrows = varargin{3}(1);
    ncols = varargin{3}(2);
end
imagesperfigure = ceil(Nin/Nout);

screensize= get(0,'ScreenSize');
sc_x = screensize(3);
sc_y =  screensize(4);

% Analyze figures
for f0=figure_handles(:)',
    fh_units = get(f0,'units');
    set(f0,'units','normalized');
    pos = get(f0,'position');
    set(f0,'units',fh_units);
end

% [TODO] Determine best tiling

% Copy figures into a single figure
for nout=1:Nout,
    fh = figure(Nopenfigures+nout);
    set(fh,'units','pixels');
    pos = get(fh,'position');
    set(fh,'units','normalized');
    rat = pos(3)/pos(4);
    if isempty(ncols),
        ncols = round(sqrt(imagesperfigure/rat));
        nrows = ceil(imagesperfigure/ncols);
    end
    left = 0;top  = 1;width = 1;height=1;
    if 0,
	ah = gca; pos = get(gca,'position'); delete(ah);
	left = pos(1);top = pos(2)+pos(4);width=pos(3);height=pos(4);
    end
    colwidth  = width/ncols;
    rowheight = height/nrows;
    count = 0;
    for r0 = 1:nrows,
        for c0 = 1:ncols,
            count = count +1;
            l = left+(c0-1)*colwidth;
            b = top-r0*rowheight;
            w = colwidth;
            h = rowheight;
            ax(count) = axes('position',[l b w h]);
        end
    end
    for nin=1:[imagesperfigure-max(0,nout*imagesperfigure-Nin)],
        input_fh = figure_handles((nout-1)*imagesperfigure+nin);
        h = get(input_fh,'Children');
        set(flipud(h),'Parent',fh);
        %newh = copyobj(h,fh);
        possub = get(ax(nin),'Position');
        for ch0 = 1:length(h)
            posnewh = get(h(ch0),'Position');
            oldpos(ch0,:)  = posnewh;
            newpos(ch0,:) = [possub(1)+posnewh(1)*possub(3) possub(2)+posnewh(2)*possub(4) posnewh(3)*possub(3) posnewh(4)*possub(4)];
            set(h(ch0),'Position',newpos(ch0,:))
        end
        if length(h)>0
            axesdata.fig     = fh;
            axesdata.handles = flipud(h);
            axesdata.oldpos  = flipud(oldpos);
            axesdata.newpos  = newpos;
        end
        setappdata(fh,sprintf('axes%d',nin),axesdata);
        str2 = '';
        str1 = '';sprintf('fh = figure(''units'',''normalized'');d=getappdata(%d,''axes%d'');setappdata(fh,''axes%d'',d);set(d.handles,''Parent'',fh,''ButtonDownFcn'',''%s'');for i0=1:length(d.handles),set(d.handles(i0),''position'',d.oldpos(i0,:));end',fh,nin,nin,str2);
        %set(h,'ButtonDownFcn',str1);
        %	pause;
        close(input_fh);
    end
    delete(ax);
end

