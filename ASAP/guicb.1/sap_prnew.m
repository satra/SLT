function sap_prnew(data)
% SAP_PRNEW 
%  SAP_PRNEW creates a new A.S.A.P project

%   Satrajit Ghosh, SpeechLab, Boston University. (c)2001
%   $Revision: 2 $  $Date: 10/08/02 2:36p $

if nargin == 0,
    handles = guihandles(gcbf);
    config = getappdata(gcbf,'config');
    
    if getappdata(handles.sap_mainfrm,'openflag'),
        if ~sap_prclose,
            return;
        end;
    end;
    
    fig = SAPprnew;
    centerfig(fig,handles.sap_mainfrm);
    data = guidata(fig);
    data.config = config;
    guidata(fig,data);
    
    uiwait(fig);
    
    data = guidata(fig);
    data.init = 1;
    closereq;
end;

if data.setflag,
    fdata.filename = data.filename;
    fdata.pathname = data.pathname;
    fdata.fullsrc  = fullfile(data.pathname,data.filename);
    fdata.projfile = data.projfile;
    fdata.projpath = data.projpath;
    fdata.fullproj = fullfile(data.projpath,data.projfile);
    
    % read data
    if data.convert,
        % Old style
        %[imgdata,otldata,offset] = sap_convert(fdata.fullsrc,handles);    
        % new style
        % pickup data lying in the directory
        V =spm_vol(fdata.fullsrc);
        [pth,nm,xt] = fileparts(fdata.fullsrc);
        imgdata = spm_read_vols(V);
        offset = [0 0 0];
        fdata.otlfile = [pth filesep nm '_otl.mat'];
	try
	    load(fdata.otlfile);
	catch
	    %% TODO add neurological coordinate question
	    qans = questdlg('Is the data normalized?',...
			    'Project New:',...
			    'Yes','No','Yes');
	    switch qans,
	     case 'Yes',
	      normalized_flag = 1;
	     case 'No',
	      normalized_flag = 0;
	    end;
	    projfile = roi_asap_preprocess(fdata.fullsrc,normalized_flag);
	    sap_command('open',projfile);
	    return;
	end
        imgdata =imgdata(crop.Crop_X,crop.Crop_Y,crop.Crop_Z);
        offset = [crop.Crop_X(1),crop.Crop_Y(1),crop.Crop_Z(1)];
        otldata = otl; clear otl crop;
    else,
        %V =spm_vol(fdata.fullsrc);
        %imgdata = spm_read_vols(V);
        imgdata = sap_reslice(fdata.fullsrc,1);
        offset = [0 0 0];
        otldata(size(imgdata,2)).lines = {};
    end;
    imgdata = uint8(255*(imgdata-min(imgdata(:)))/(max(imgdata(:))-min(imgdata(:))));
    
    curpos = [round(size(imgdata)/2) 1];
    slicemod(1:size(imgdata,2)) = 0;
    load('sap_collist.spt','-MAT','collist');
    sulcdata.num = 1;
    sulcdata.cols = collist;
    sulcdata.ptlist(1:length(collist)) = {{}};
    nodedata = zeros(4,30,2,3);
    parcdata(size(imgdata,2)).lines = {};
    regdata(size(imgdata,2)).lines = {};
    
    if data.init,
        saveflag = 1;
        openflag = 1;
        sap_init;    
    else,
        if ~exist(fdata.fullproj,'file'),
            save(fdata.fullproj,'-MAT','fdata','imgdata','curpos','offset',...
                'otldata','slicemod','sulcdata','nodedata','parcdata','regdata');
        else,
            disp('ASAP Project file exists, not creating new file');
        end;
    end;
end;
