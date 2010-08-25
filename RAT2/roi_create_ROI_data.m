function expt = roi_create_ROI_data(expt,sid,FLAG,maskid)
% FUNCTION EXPT = ROI_CREATE_ROI_DATA(EXPT) extracts ROI data from
% the functional runs for all subjects based on the masks stored in
% the roisession structure (see roi_setup_expt.m for details). The
% extracted data is stored in the same directory where the mask
% file is generated/stored and is indexed by subject name and
% session.
%
% EXPT = ROI_CREATE_ROI_DATA(EXPT,SID) allows one to specify which
% subjects' data should be extracted. If SID is left empty all
% subjects' data are extracted. 
%
% EXPT = ROI_CREATE_ROI_DATA(EXPT,SID,FLAG) controls the process of
% data extraction. FLAG is a 2 element boolean vector: 
%                [doExtract, doSmooth]
% The first element controls data extraction. In the event that one
% has already generated the data, leaving this flag unset (0)
% prevents reextraction of data. However, the fields of the EXPT
% structure are filled with the appropriate data pointers. 
% [TODO: doSmooth is a redundant flag currently. In the future, it
% will provide within the region smoothing. The second flag is
% ignored if the first flag is set to 0.] 
%
% EXPT = ROI_CREATE_ROI_DATA(...,MASKID) is a string input that
% gets appended to the directory names. This allows creating
% different data sets with different masks. 
%
% See also: @EXPERIMENT, ROI_SETUP_DEMO, 

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Id: roi_create_ROI_data.m 122 2005-11-29 08:39:13Z satra $

% $NoKeywords: $

% Initialize SPM
spm_defaults;

if nargin<2 | isempty(sid),
    sid = 1:length(expt.subject);
end;
sid = sid(:)';
if nargin<3 | isempty(FLAG),
    FLAG = [1 0];
end;
if nargin<4,
    maskid = '';
end

doExtract       = 1 & FLAG(1);
doSmooth        = 1 & FLAG(2);

roi_write_log('roi_create_ROI_data: Starting ROI extraction');
roi_write_log(['roi_create_ROI_data: subjects ',num2str(sid)]);
[labels,labelid] = roi_load_labels;

hasSPH = 1; % Boolean flag indicating existence of spherical
            % coordinate data from freesurfer

for subjno=sid,
    id2keep = {};
    for sessno=1:length(expt.subject(subjno).roidata),
	if expt.subject(subjno).roidata(sessno).issurf,
	    %% TODO: [add surface 2 volume transform]
	else,
	    maskfile = expt.subject(subjno).roidata(sessno).mask;
	    [pth,nm,xt] = fileparts(maskfile);
	    roidir = sprintf('%sSubject.%02d.roifuncdata.%03d',maskid,subjno,sessno);
	    s = mkdir(pth,roidir);
	    roidir = fullfile(pth,roidir);
	    Vmask    = spm_vol(maskfile);
	    M        = Vmask.mat;

	    fprintf('Reading mask file\n');
	    Y = round(spm_read_vols(Vmask));
	    NPU = setdiff(unique(round(Y(:))),[0;32767]); % get all labels

	    % Not assuming the size of functional data
	    % Get indices to voxels from mask data
	    if doExtract,
		if expt.design.useSPHcoords,
		    try
			load(spm_get('Files',fileparts(expt.subject(subjno).roidata(sessno).mask),'SURF2RAT*ID2SPH.mat'),'-MAT');
			expt.design.useSPHcoords = 1;
			VFS = spm_vol(spm_get('Files',fileparts(expt.subject(subjno).roidata(sessno).mask),'SURF2RAT*.img'));
			YFS = round(spm_read_vols(VFS));
			autoPU = unique(setdiff(YFS(:),0));
			roi_write_log('Using spherical coordinates');
		    catch
			hasSPH = 0;
			expt.design.useSPHcoords = 0;
			roi_write_log(['Not using spherical coordinates' ...
				       ' because mask file was not found']);
		    end
		else
		    hasSPH = 0;
		    roi_write_log(['Not using spherical coordinates' ...
				   ' by design']);
		end

		fprintf('Getting voxel indices %3d/%3d',0,0);
		for npu=1:length(NPU),
		    [x,y,z] = ind2sub(size(Y),find(Y(:)==NPU(npu)));
		    idxPU{npu} = [x,y,z];
		    if hasSPH,
			sphPU{npu} = dsph.idx2sph(find(Y(:)==NPU(npu)),:);
		    end;
		    fprintf('%s%3d/%3d',char(sprintf('\b')*ones(1,7)),npu,length(NPU));
		end;
		fprintf('%s...Done\n',char(sprintf('\b')*ones(1,7)));
	    end
	end;
	
	if doExtract,
	    V = spm_vol(expt.subject(subjno).functional(sessno).pp_affine);
	    Ymask = zeros(V(1).dim(1:3));

	    gx = [];
	    fprintf('Calculating globals %3d of %3d',0,0);
	    for nimage=1:length(V), 
		gx(nimage,1)=spm_global(V(nimage)); 
		fprintf('%s%3d of %3d',char(sprintf('\b')*ones(1,10)),nimage,length(V));
	    end
	    fprintf('%s...Done\n',char(sprintf('\b')*ones(1,10)));

	    % Get indices to functional voxels for each ROI
	    fprintf('Changing voxel indices %3d/%3d',0,0);
	    for npu=1:length(NPU),
		% Subfunction defined below
		[idxPU{npu},idx1,I,J] = roi_xyz2idx(idxPU{npu},M,V(1).mat, ...
					 V(1).dim);
		if hasSPH,
		    sphPU{npu} = sphPU{npu}(I,:);
		end
		R{npu} = zeros(length(V),length(idxPU{npu}));
		Ymask(idxPU{npu}) = NPU(npu);
		fprintf('%s%3d/%3d',char(sprintf('\b')*ones(1,7)),npu,length(NPU));
		%fprintf('%-10s: %d\n',labels{find(labelid==NPU(npu))},length(idxPU{npu}));
	    end;
	    fprintf('%s...Done\n',char(sprintf('\b')*ones(1,7)));
	    Vmask = V(1);
	    Vmask.fname = 'testmask.img';
	    spm_write_vol(Vmask,Ymask);

	    fprintf('Reading file %4d of %4d',0,length(V));
	    for nvol=1:length(V),
		fprintf('%s%4d of %4d',char(sprintf('\b')*ones(1,12)),nvol,length(V));
		Y = spm_read_vols(V(nvol));
		for npu=1:length(NPU),
		    R{npu}(nvol,:) = Y(idxPU{npu})';
		end;
	    end;
	    fprintf(' ... Done\n');

	    fprintf('Scaling %3d of %3d',0,length(NPU));
	    for npu=1:length(NPU),
	    	fprintf('%s%3d of %3d',char(sprintf('\b')*ones(1,10)), ...
	    		npu,length(NPU));
		if length(id2keep)<NPU(npu),
		    id2keep{NPU(npu)} = find(all(R{npu}>repmat(gx(:)/4,1,size(R{npu},2))));
		else,
		    id2keep{NPU(npu)} = intersect(id2keep{NPU(npu)}, ...
					      find(all(R{npu}>repmat(gx(:)/4,1,size(R{npu},2)))));
		end;
		%if any([32036,36]==NPU(npu)),
		%    keyboard;
		%end
	    	R{npu} = R{npu}/mean(gx)*100;
		% idxPU{npu} = idxPU{npu}(id2keep);
	    end;
	    fprintf(' ... Done\n');
	end;

	PP = {};
	didnotSmooth = [];
	fprintf('Writing/Assigning PUfiles for session[%2d] %3d/%3d',sessno,0,0);

	for npu=1:length(NPU), % JT removed JB edit 03/07/04
	    PUlabel = labels{find(labelid==NPU(npu))};
	    filename = fullfile(roidir,sprintf('Subject.%02d.ROI.%s_%05d.%03d.mat', ...
					       subjno,deblank(PUlabel),NPU(npu),sessno));
	    PP{npu} = filename;
	    if doExtract,
		PUdata = R{npu};
		PUidx  = idxPU{npu};
		if hasSPH,
		    xyz    = sphPU{npu}; 
		else,
		    xyz = roi_idx2mm(PUidx,V(1));
		end
		xyzCart= roi_idx2mm(PUidx,V(1));

		xY.xyz = nanmean(xyz)';
		xY.name= deblank(PUlabel);
		xY.Ic  = 0;
		xY.Sess= sessno;
		xY.def = 'cluster';
		xY.XYZmm=xyz';
		xY.XYZCart = xyzCart';
		xY.y   = PUdata;
		xY.PUidx = PUidx;
		xY.gx  = gx;

		if doSmooth,
		    % TODO: Do different smoothing for surface ROIs
		    try
			PUdata = roi_smoothROI(PUdata,idxPU{npu}, ...
					       V(1).dim, ...
					       expt.design.roiSmoothFWHM,V(1).mat);
			xY.smooth = 1;
		    catch,
			xY.smooth = 0;
			didnotSmooth = [didnotSmooth;[NPU(npu) size(PUdata,2)]];
		    end
		    xY.y = PUdata;
		end;
		save(filename,'xY');
	    end;
	    fprintf('%s%3d/%3d',char(sprintf('\b')*ones(1,7)),npu,length(NPU));
	end;
	fprintf('%s...Done\n',char(sprintf('\b')*ones(1,7)));
	if doSmooth,
	    fprintf('The following ids were not smoothed. [Size in 2nd column.]\n');
	    didnotSmooth
	end
	expt.subject(subjno).roidata(sessno).data   = char(PP);
	expt.subject(subjno).roidata(sessno).PUlist = NPU(:);
    end;

    if doExtract,
	noSPHdata = {};
	fprintf('Removing voxels [%d] %3d of %3d',0,0,0);
	for sessno=1:length(expt.subject(subjno).roidata),
	    fprintf('%s[%d] %3d of %3d',char(sprintf('\b')*ones(1,14)), ...
		    sessno,0,0);
	    for npu=1:size(expt.subject(subjno).roidata(sessno).data,1),
	    	fprintf('%s%3d of %3d',char(sprintf('\b')*ones(1,10)), ...
	    		npu,size(expt.subject(subjno).roidata(sessno).data,1));
		load(deblank(expt.subject(subjno).roidata(sessno).data(npu,:)),'-mat');
		idx = id2keep{expt.subject(subjno).roidata(sessno).PUlist(npu)}(:)';
		xY.y = xY.y(:,idx);
		xY.PUidx = xY.PUidx(idx);
		if hasSPH,
		    PUlabel = labels{find(labelid==NPU(npu))};
		    if ~isempty(intersect(NPU(npu),autoPU))
			xyz    = sphPU{npu}(idx,:); 
		    else
			xyz    = NaN*sphPU{npu}(idx,:); 
			noSPHdata = [noSPHdata;{PUlabel}];
		    end
		else,
		    xyz = roi_idx2mm(xY.PUidx,V(1));
		end;
		xyzCart= roi_idx2mm(xY.PUidx,V(1));
		xY.xyz = mean(xyz)';
		xY.XYZmm=xyz';
		xY.XYZCart = xyzCart';
		%if ~hasSPH,
		%    xY = rmfield(xY,'xyz');
		%end
		save(deblank(expt.subject(subjno).roidata(sessno).data(npu,:)),'xY','-mat');
	    end;
	end
	clear xY;
	fprintf(' ... Done\n');
	noSPHdata
    end
end;
roi_write_log('roi_create_ROI_data: Done ROI extraction');

function xyz = roi_idx2mm(idx,V)
[x,y,z] = ind2sub(V.dim(1:3),idx);
xyz = [x,y,z,ones(length(x),1)]';
xyz = V.mat*xyz;
xyz = xyz(1:3,:)';

