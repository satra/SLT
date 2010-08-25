function varargout = sap_labelcb(h,eventdata,handles,varargin);
% SAP_LABELCB Callback routine for region related issues
%   SAP_LABELCB handles various requests made during the label
%   mode. 
%   The first argument of the varargin determines the action for 
%   the callback. THe subsequent arguments depend on the type of
%   the first one and are listed with each callback action code.

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/guicb.1/sap_labelcb.m 8     10/08/02 2:36p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

%global mask tmp ROImask i

% To redo labels set the following flag to 1. After labels are done set this 
% back to zero. Performing this operation sets all labels back to None.
% USE WITH CAUTION!!!


cbtype = varargin{1};
switch cbtype,
case 'btndown',
    bSet2None = get(handles.sap_setnone,'value');
    if bSet2None,
        clientdata = getappdata(handles.sap_mainfrm,'clientdata');
        udata = clientdata.curlinedata;
        if isempty(udata),
            return;
        end;
        clientdata.curlinedata = [];
        setappdata(handles.sap_mainfrm,'clientdata',clientdata);
        i = udata.slnum;
        j = udata.idx;
        regdata = getappdata(handles.sap_mainfrm,'regdata');    
        sap_status(handles,char(regdata(i).lines{j}.label));
        regdata(i).lines{j}.labelid = 3;
        regdata(i).lines{j}.label = 'None';
        setappdata(handles.sap_mainfrm,'regdata',regdata);
        setappdata(handles.sap_mainfrm,'saveflag',1);
        sap_titlechange(handles.sap_mainfrm,1);
        
        sap_clientmanager('refreshcl',h,eventdata,handles);    
        return;
    end;
    bSet2label = get(handles.sap_set2label,'value');
    if bSet2label,
      sap_labelcb(h,eventdata,handles,'setlabel');
      return;
    end
    
    slnum = getfield(get(h,'userdata'),'slnum');
    pt = get(h,'currentpoint');
    pt = round(pt(1,1:2));
    curplane = get(handles.sap_planesel,'value');
    curpos = sap_updatecurpos(curplane,slnum,pt);
    setappdata(handles.sap_mainfrm,'curpos',curpos);
    setappdata(handles.sap_mainfrm,'oldbval',1);
    sap_clientmanager('update',[],[],handles,'position',2);
    
    nodevalid = get_nodevalid(handles,curpos);    
    if isempty(nodevalid),
        return;
    end;
    
    regions = sap_expert1(nodevalid);    
    [PU,id] = sap_PUlist;
    str = '';
    for i=1:length(regions);
        str = sprintf('%s %s',str,PU{find(id==regions(i))});
        labelcell{i} = PU{find(id==regions(i))};
    end;
    if ~isempty(regions),
        sap_modifylabelcontextmenu(handles,labelcell,regions);
    end
    sap_status(handles,str);
case 'createregions',
    otldata = getappdata(handles.sap_mainfrm,'otldata');
    parcdata = getappdata(handles.sap_mainfrm,'parcdata');
    regdata = getappdata(handles.sap_mainfrm,'regdata');
    slicemod = getappdata(handles.sap_mainfrm,'slicemod');
    bRedoLabel = get(handles.sap_redolabel,'value');
    if bRedoLabel,
        set(handles.sap_redolabel,'Value',0);
        sap_status(handles,'Redoing all labels');
    end;
    sap_status(handles,'creating regions');
    
    if bRedoLabel,
        slicemod(:) = 1;
    end;
    idx = find(slicemod);
    if ~isempty(idx),
        setappdata(handles.sap_mainfrm,'saveflag',1);
        sap_titlechange(handles.sap_mainfrm,1);
    else,
        return;
    end;
    imgdata   =   getappdata(handles.sap_mainfrm,'data');
    sx = size(imgdata,1);
    sy = size(imgdata,2);
    sz = size(imgdata,3);
    clear imgdata;
    
    ct = 0;
    if bRedoLabel,
        slicemod(:) = 0;
    end;
    
    hproc = uiwaitbar('Generating slice mask');
    % create labelmask for all parcellated slices
    blabelled = 0;
    parcidx = [];
    if bRedoLabel,
        maskidx = 1:sy;
    else,
        maskidx = idx;
    end;
    
    for i=maskidx,
        labelmask{i} = [];
        if ~isempty(parcdata(i).lines),
            parcidx = [parcidx,i];
            labelmask{i} = double(sap_getlabelmask(regdata(i),sx,sz));
            if ~isempty(labelmask{i}),
                blabelled = 1;
            end;
        end
        uiwaitbar(find(maskidx==i)/length(maskidx),hproc);
    end
    
    uiwaitbar(0,hproc,'title','Updating modified slices');
    % Update modified slices
    for i=idx,%~(isempty(otldata(i).lines) & isempty(parcdata(i).lines)),
        regdata(i).lines = {};
        if ~(isempty(parcdata(i).lines)),
            %i
            ct = ct+1;
            multf = 2;
            mask = sap_getmask(otldata(i).lines,parcdata(i).lines,multf);
            slicemod(i) = 0;
            lines = sap_getmasklines(mask,multf);      
            regdata(i).lines = lines;
        end;
        uiwaitbar(find(idx==i)/length(idx),hproc);
    end;
    
    % propagate labels & restrict based on expert system
    if blabelled & bRedoLabel,
        uiwaitbar(0,hproc,'title','Propagating masks');
        left_mask = zeros(sx,sz);
        left_mask(1:round(sx/2),:) = 1;
        right_mask = 1 - left_mask;
        for i=parcidx,
            nodevalid_lt = get_nodevalid(handles,round([sx/4,i,sz/2,2]));
            nodevalid_rt = get_nodevalid(handles,round([3*sx/4,i,sz/2,2]));
            if ~isempty(nodevalid_lt)
                regions_left = sap_expert1(nodevalid_lt);
            end;
            if ~isempty(nodevalid_rt)
                regions_right = sap_expert1(nodevalid_rt);
            end;
            if ~isempty(nodevalid_lt) | ~isempty(nodevalid_rt),
                if isempty(labelmask{i}),
                    labelmask{i} = zeros(sx,sz);
                else,
                    regions_left  = unique(union(regions_left,unique(labelmask{i}.*left_mask)));
                    regions_right = unique(union(regions_right,unique(labelmask{i}.*right_mask)));
                end;
                loc = find(parcidx==i);
                if loc>1 & ~isempty(labelmask{parcidx(loc-1)}),
                    premask = sap_blockregions(labelmask{parcidx(loc-1)},left_mask,right_mask,regions_left,regions_right);
                    if ~isempty(premask),
                        labelmask{i} = labelmask{i} + (~labelmask{i}).*premask;
                    end;
                end;
                if loc<length(parcidx),
                    for j=parcidx((loc+1):end);
                        if ~isempty(labelmask{j}),
                            labelmask{i} = labelmask{i} + (~labelmask{i}).*labelmask{j};
                        end;
                    end;
                end;
                %% [To add] Keep the expert labelled regions determined earlier
                labelmask{i} = sap_blockregions(labelmask{i},left_mask,right_mask,regions_left,regions_right);
                uiwaitbar(find(parcidx==i)/length(parcidx),hproc);
            end;
        end;
    end;
    
    %load labelmaskdata;
    % Assign new labels
    [PU,id] = sap_PUlist;
    if bRedoLabel,
        reidx = parcidx;
        hproc = uiwaitbar(0,hproc,'title','Redoing all labels');
    else,
        reidx = idx;
        hproc = uiwaitbar(0,hproc,'title','Labelling modified slices');
    end;

    for i=reidx,%~(isempty(otldata(i).lines) & isempty(parcdata(i).lines)),
        tmpmask = labelmask{i};
        if ~isempty(tmpmask),
            numlines = length(regdata(i).lines);
            if numlines>0,
                regmask = double(sap_getlabelmask(regdata(i),sx,sz,0,0,0,1));
                lines2use = setdiff(unique((tmpmask>0).*regmask),0);
                for j=lines2use(:)',
                    regvals = tmpmask(find(regmask(:)==j))';
                    [h,x] = hist(regvals,[0 setdiff(unique(regvals),0)]);
                    [mx,mi] = max(h(2:end));
                    if mx/length(regvals)>0.5,
                        lid = x(1+mi);
                    else,
                        lid = 0;
                    end
                    if lid==0,
                        lid = 3;
                    end;
                    lname = PU(find(id==lid));
                    regdata(i).lines{j}.label = char(lname);
                    regdata(i).lines{j}.labelid = double(lid);
                end;
            end;
        end;
        uiwaitbar(find(reidx==i)/length(reidx),hproc);
    end;
    delete(hproc);
    
    setappdata(handles.sap_mainfrm,'slicemod',slicemod);
    
    sap_status(handles,'done creating regions');
    
    setappdata(handles.sap_mainfrm,'regdata',regdata);
case 'refresh',
    curpos = getappdata(handles.sap_mainfrm,'curpos');    
    if curpos(4) ~=2,
        return;
    end;
    axh = varargin{2};
    if nargin == 6,
        bhitoff = 1;
    else
        bhitoff = 0;
    end;
    sap_status(handles,['label: refresh b-' num2str(bhitoff)]);
    
    regdata = getappdata(handles.sap_mainfrm,'regdata');
    load('labelcols.spt','-MAT','labelcols');
    %PU = sap_PUlist;
    for j=1:length(axh),
        sap_clientmanager('deleteobj',[],[],handles,'reghandles',axh(j));
        udata = get(axh(j),'userdata');
        slnum = udata.slnum;
        numlines = length(regdata(slnum).lines);
        if numlines>0,
            lhdl = [];
            axes(axh(j));hold on;
            for i=1:numlines,
                ptlist = regdata(slnum).lines{i}.ptlist;
                udata.slnum = slnum;
                udata.idx = i;
                udata.axh = axh(j);
                udata.mode= 'label';
                udata.marker = 0;
                str = 'sap_clientmanager(''buttondowncb'',gcbo,[],guihandles(gcbf),''linesel'');';                
                %labelid = find(strcmp(regdata(slnum).lines{i}.label,PU));
                %regdata(slnum).lines{i}.labelid = labelid;
                if strcmp(regdata(slnum).lines{i}.label,'None'),
                    if bhitoff,
                        %                         lhdl(i) = patch(ptlist(:,1),ptlist(:,2),1,...
                        %                             'HitTest','off',...
                        %                             'userdata',udata);
                    else,
                        lhdl(i) = patch(ptlist(:,1),ptlist(:,2),1,...
                            'userdata',udata,...
                            'ButtonDownFcn',str,...
                            'UIcontextmenu',handles.sap_labelmenu);
                        if lhdl(i)>0,
                            set(lhdl(i),'Facecolor','none','Edgecolor','w'); %,'Facealpha',0.5);
                        end;
                    end;
                else,
                    if bhitoff,
                        lhdl(i) = patch(ptlist(:,1),ptlist(:,2),1,...
                            'HitTest','off',...
                            'userdata',udata);
                    else,
                        lhdl(i) = patch(ptlist(:,1),ptlist(:,2),1,...
                            'userdata',udata,...
                            'ButtonDownFcn',str,...
                            'UIcontextmenu',handles.sap_labelmenu);
                    end;
                    if lhdl(i)>0,
                        set(lhdl(i),'Facecolor',labelcols(regdata(slnum).lines{i}.labelid,:),'Edgecolor','w'); %,'Facealpha',0.3);
                    end;
                    %set(lhdl(i),'Facecolor',rand(1,3),'Edgecolor','w'); %,'Facealpha',0.5);
                end;
            end;
            lhdl = lhdl(find(lhdl));
            %set(lhdl,'Facealpha',0.1');
            sap_clientmanager('addclient',lhdl,[],handles,'regclient',axh(j));
        end;
    end;
    %setappdata(handles.sap_mainfrm,'regdata',regdata);
    %setappdata(handles.sap_mainfrm,'saveflag',1);
    %sap_titlechange(handles.sap_mainfrm,1);
    
    %refresh(gcbf);
case 'setlabel',
    if length(varargin)<2,
      try
        labelid = getappdata(handles.sap_mainfrm,'last_labelid');
        if isempty(labelid),
          return;
        end
        labelname = getappdata(handles.sap_mainfrm,'last_labelname');
      catch
        return;
      end
    else
      labelid = varargin{2};
      labelname = varargin{3};
    end
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    udata = clientdata.curlinedata;
    clientdata.curlinedata = [];
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
    i = udata.slnum;
    j = udata.idx;
    
    regdata = getappdata(handles.sap_mainfrm,'regdata');    
    regdata(i).lines{j}.label = labelname;  
    regdata(i).lines{j}.labelid = labelid;  
    setappdata(handles.sap_mainfrm,'last_labelname',labelname);
    setappdata(handles.sap_mainfrm,'last_labelid',labelid);
    setappdata(handles.sap_mainfrm,'regdata',regdata);
    setappdata(handles.sap_mainfrm,'saveflag',1);
    sap_titlechange(handles.sap_mainfrm,1);
    
    sap_clientmanager('refreshcl',h,eventdata,handles);    
case 'showlabel',
    clientdata = getappdata(handles.sap_mainfrm,'clientdata');
    udata = clientdata.curlinedata;
    clientdata.curlinedata = [];
    setappdata(handles.sap_mainfrm,'clientdata',clientdata);
    i = udata.slnum;
    j = udata.idx;
    regdata = getappdata(handles.sap_mainfrm,'regdata');    
    sap_status(handles,char(regdata(i).lines{j}.label));
case 'extractroi'
    fdata   =   getappdata(handles.sap_mainfrm,'fdata');
    sap_createROImask(fdata.fullproj);
%     
%     regdata = getappdata(handles.sap_mainfrm,'regdata');
%     parcdata = getappdata(handles.sap_mainfrm,'parcdata');
%     sap_status(handles,'Extracting ROI');
%     imgdata   =   getappdata(handles.sap_mainfrm,'data');
%     ROImask = uint16(zeros(size(imgdata)));
%     sx = size(ROImask,1);
%     sz = size(ROImask,3);
%     hproc = waitbar(0,'Getting labels','units','normalized','Position',[0.1 0.1 0.35 0.1]);    
%     multf = 1;
%     sliceidx = [];
%     for i=1:length(regdata),
%         numlines = length(regdata(i).lines);
%         if numlines>0 & ~(isempty(parcdata(i).lines)),
%             mask = zeros(256,256);
%             sliceidx = [sliceidx; i];
%             for j=1:numlines,
%                 %regdata(i).lines{j}.label;
%                 if ~strcmp(regdata(i).lines{j}.label,'None'),
%                     labelid = regdata(i).lines{j}.labelid;
%                     tmp = labelid*double(bwfill(sap_getmask(regdata(i).lines(j),[],multf),'holes'))';
%                     mask = mask+tmp+0.1*(tmp>0);
%                 end;
%             end;
%             mask2 = mask-fix(mask);
%             idx = find(mask2(:)>0.15);
%             mask(idx) = 0;
%             ROImask(:,i,:) = uint16(fix(mask(1:sx,1:sz)));
%         end;
%         waitbar(i/length(regdata),hproc);        
%     end;
%     close(hproc);
% 
%     fdata   =   getappdata(handles.sap_mainfrm,'fdata');
%     offset  = getappdata(handles.sap_mainfrm,'offset');
%     
%     fname = sprintf(['../rawimages/corr_%s'],strtok(fdata.projfile,'.'));
%     V2 = spm_vol(fname);
%     H.Data1 = uint16(spm_read_vols(V2));
%     ROImask2 = uint16(zeros(size(H.Data1)));
%     ROImask2(...
%         offset(1)-1+[1:size(ROImask,1)],...
%         offset(2)-1+[1:size(ROImask,2)],...
%         offset(3)-1+[1:size(ROImask,3)]) = ROImask;
% 
%     step = mod(offset(2)-1+sliceidx(1),3);
%     if step==0,step = 3;end;
%     idx = [1:size(ROImask2,2)];
%     idx = idx(step:3:end);
%     
%     ROImask2 = ROImask2(:,idx,:);
%     ROImask2 = sap_reindex(ROImask2,fix(offset(1)-1+size(ROImask,1)/2));
%     
%     %    imgdata = imgdata(:,idx,:);
%     imgdata = H.Data1(:,idx,:);
%     [s,r] = strtok(fdata.projfile,'-');
%     subjinit = strtok(r(2:end),'-');
%     
%     V.fname = sprintf('%s_Subject_ROI.img',subjinit);
%     V.dim = [size(ROImask2) 4];
%     V.pinfo = [0 0 0]';
%     V.descrip = '';
%     V.mat = diag([1 3 1 1]);
%     sth = diag(V.mat);
%     V.mat(1:3,4) = -1*sth(1:3).*[size(ROImask2)/2]';
%     V1 = V;
%     V1.fname = sprintf('%s_Subject_ROIStruct.img',subjinit);
%     [V.fname]
%     pdir = pwd;
%     cd(fdata.projpath);
%     spm_write_vol(V,ROImask2(end:-1:1,:,:));
%     spm_write_vol(V1,imgdata);
%     cd(pdir);
end;

function nodevalid = get_nodevalid(handles,curpos);
nodevalid = [];
nodedata = getappdata(handles.sap_mainfrm,'nodedata');
maxnodes = size(nodedata,2);
maxseries = size(nodedata,1);
nodedata = permute(nodedata,[3 4 2 1]);
nodedata = nodedata(:,:,:);
nodedata = permute(nodedata,[3 1 2]);

nodes = sap_nodelist;
idx = zeros(maxseries*maxnodes,1);
for i=1:length(nodes),
    idx(maxnodes*(i-1)+nodes(i).id(:)) = 100*i+nodes(i).id(:);
end;
nodenum = idx(find(idx));
idx = find(idx);

%load('nodesidx.spt','-MAT','idx','nodenum');
nodedata = nodedata(idx,:,:);
midpt = getappdata(handles.sap_mainfrm,'midpt');
if curpos(1)<midpt,
    side = 2;   % left
else,
    side= 1;    % right
end;

y = curpos(2);
yvals = squeeze(nodedata(:,side,2));
[syvals,id] = sort(yvals);

validnodes = find(syvals);
if isempty(validnodes), % nodes not yet set
    return;
end;

syvals = syvals(validnodes);
id = id(validnodes);

idx = find(y<syvals);
if isempty(idx),
    return;
end;
nodevalid = unique(nodenum(id(idx)));

function   premask = sap_blockregions(mask,left_mask,right_mask,regions_left,regions_right);
maskleft = zeros(size(mask));
maskright= zeros(size(mask));
% modify left masks
if ~isempty(regions_left),
    tmpmask = mask.*left_mask;
    numregions = intersect(unique(tmpmask),regions_left);
    %fprintf('Left[%d]\n',length(numregions));
    if ~isempty(numregions),
        for r=numregions(:)',
            maskleft = maskleft + r.*(tmpmask==r);
        end;
    end;
end;
% modify right masks
if ~isempty(regions_right),
    tmpmask = mask.*right_mask;
    numregions = intersect(unique(tmpmask),regions_right);
    %fprintf('Right[%d]\n',length(numregions));
    if ~isempty(numregions),
        for r=numregions(:)',
            maskright = maskright + r.*(tmpmask==r);
        end;
    end;
end;
premask = maskleft+maskright;
if length(unique(premask))==1,
    premask = [];
end;
