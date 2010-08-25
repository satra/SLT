function ans=spm_ROI_input(opt,force,name);
% spm_ROI_input Input data project management tool
% spm_ROI_input(fieldname) will return the value of the project field with name 'fieldname' in the current spm_ROI project.
% If this value has not been defined spm_ROI_input will prompt the user to enter it.
% Valid fieldname strings are
%                files.path_subject                     Cell array with each subject directory
%                files.name_structural                  Cell array with each subject structural data file
%                files.name_hires                       Cell array with each subject HiRes data file
%                files.name_functional                  Double cell array with each subject x session functional data files
%                files.name_roistruct                   Cell array with each subject ROI structural data file
%                files.name_roimask                     Cell array with each subject ROI mask data file
%                files.name_roilabel                    ROI labels file
%                files.name_roiproject                  Cell array with each subject ROI project data file
%                files.name_experiment                  Experiment project file
%                model.RemoveGlobal                     1/0: regress global activation
%                model.Detrend                          1/0: detrend functional series
%                model.SmoothFWHM                       FWHM (seconds) intra region smoothing
%                model.RepetitionTime                   TR (seconds)
%                model.DataReductionType                'FFT'/'SVD' Type of data reduction applied
%                model.DataReductionLevel               Number of eigenvariates kept
%                model.MinPeriod                        Minimum period of interest (seconds)
%                model.MaxPeriod                        Maximum period of interest (seconds)
%                model.ContrastSpatialVector            String specifying the functional form of the spatial contrast vector
%                model.DesignMatrix                     Cell array with the design matrix for each subject
%                model.ContrastVector                   Cell array with each contrast on the effects
%                model.ContrastName                     Cell array with the names of these contrasts
%                model.Level2DesignMatrix               2nd level design matrix (number of subjects x number of 2nd level effects)
%                model.Level2ContrastVector             Cell array with each contrast on the 2nd level effects
%                model.Level2ContrastName               Cell array with the names of these contrasts
%
% spm_ROI_input(fieldname, fieldvalue) will set the value of fieldname to fieldvalue
% If fieldvalue is set empty spm_ROI_input will force a user-prompt for redefining the value of the field
%
% Other spm_ROI_input options are:
% spm_ROI_input('init','open')      opens an existing project database
% spm_ROI_input('init','new')       creates a new project database
% spm_ROI_input('init','edit')      launches a gui to change the project field values
%
% Note1: some of the field values are linked (example: to set value of files.path_strucutural spm_ROI_input will use the value of path_subject to know how many subjects there are in the study)
% Note2: the name of the current project file is kept in a persistent variable that will not be cleared by a clear command. 
% If a current project has not yet been defined spm_ROI_input will prompt the user to do so the first time spm_ROI_input is used in each Matlab session.
%

% 02/02
% alfnie@bu.edu

persistent SPM_ROI SPM_ROIfile

if nargin<3, name=''; end
ans=[];
if nargin>1 & strcmp(lower(opt),'init'),    % open a project, create a new project, or launch a gui for defining project fields
    ans=SPM_ROIfile;
    switch(lower(force))
    case 'new'
        if nargin>2, [pathname,filename]=fileparts(name); 
        else,
            [filename,pathname]=uiputfile(...
                {'*.roi', 'ROI project files (*.roi)'},...
                'Create a new ROI project');
            if isequal(filename,0) | isequal(pathname,0), ans=0; return; end;
            [nill,filename]=fileparts(filename);
        end
        SPM_ROIfile=fullfile(pathname,[filename,'.roi']);
        if ~isempty(dir(SPM_ROIfile)), 
            ans=0; 
            errordlg('Overwriting existing roi projects is not permitted. Delete the file instead and create a new project','spm_ROI');
        else
            ans=SPM_ROIfile;
            SPM_ROI = struct(...
                'files', struct(...
                'path_subject',[],...
                'name_structural',[],...
                'type_structural',[],...
                'name_hires',[],...
                'type_hires',[],...
                'name_functional',[],...
                'name_roilabel',[],...
                'name_experiment',[],...
                'name_roistruct',[],...
                'name_roimask',[], ...
                'name_roiproject',[] ...
                ),...
                'model', struct(...
                'RemoveGlobal',0,...
                'Detrend',1,...
                'Whitening',1,...
                'SmoothFWHM',0,...
                'RepetitionTime',2,...
                'DataReductionType','SVD',...
                'DataReductionLevel',8,...
                'MinPeriod',4,...
                'MaxPeriod',120,...
                'ContrastSpatialVector',[],...
                'DesignMatrix',[],...
                'ContrastVector',[],...
                'ContrastName',[], ...
                'Level2DesignMatrix',[],...
                'Level2ContrastVector',[],...
                'Level2ContrastName',[] ...
                ),...
                'private', struct(...
                'SameSubjectDesign',0,...
                'AvailableRegions',[],...
                'FromFilePreprocessing',0,...
                'NeedEstimate',1, ...
                'Stage',[] ...
                ));
            save(SPM_ROIfile,'SPM_ROI');
        end
    case 'open'
        ans=1;
        if nargin>2, filename=name; 
        else, filename=spm_get(1,'.roi','Select an ROI project'); end
        if isempty(filename), ans=0; return; end;
        SPM_ROIfile=filename;
        if ~isempty(dir(SPM_ROIfile)), 
            load(SPM_ROIfile,'SPM_ROI','-mat');
            % Try to open initializatin file if it exists
            SPM_ROIinitfile=[filename(1:end-4),'.m'];
            if ~isempty(dir(SPM_ROIinitfile)),
                cwd=pwd;
                [pathname,filename]=fileparts(SPM_ROIinitfile);
                cd(pathname);
                try
                    eval(filename);
                catch
                    errordlg(strvcat(['File ',SPM_ROIinitfile,'.m contains errors!'],'Initialization file not loaded'),'spm_ROI');
                end
                cd(cwd);
            end
            ans=SPM_ROIfile;
        else
            ans=0; 
            errordlg(['File ',SPM_ROIfile,' does not exist'],'spm_ROI');
        end
    case 'edit'
        optsname={...
                'files.path_subject',...
                'files.name_structural',...
                'files.name_hires',...
                'files.name_functional',...
                'files.name_roiproject',...
                'files.name_roimask',...
                'files.name_roilabel',...
                'files.name_experiment',...
                'model.RepetitionTime',...
                'model.Whitening',...
                'model.RemoveGlobal',...
                'model.Detrend',...
                'model.SmoothFWHM',...
                'model.DataReductionType',...
                'model.DataReductionLevel',...
                'model.MinPeriod',...
                'model.MaxPeriod',...
                'model.ContrastSpatialVector',...
                'model.DesignMatrix',...
                'model.ContrastVector',...
                'model.Level2DesignMatrix',...
                'model.Level2ContrastVector'};
        [opts,ok]=listdlg(...
            'ListString',...
            {   'Data parameters: Subject-specific folder',...
                'Data parameters: Structural data files',...
                'Data parameters: HiRes data files',...
                'Data parameters: Functional data files',...
                'Data parameters: ROI project files',...
                'Data parameters: ROI data files',...
                'Data parameters: ROI labels file',...
                'Data parameters: Experiment file',...
                'Data parameters: Repetition Time (RT)',...
                'Analysis parameters: Perform whitening',...
                'Analysis parameters: Remove global effects',...
                'Analysis parameters: Detrending',...
                'Analysis parameters: Smoothing',...
                'Analysis parameters: Data reduction type',...
                'Analysis parameters: Data reduction level',...
                'Analysis parameters: Minimum period of interest',...
                'Analysis parameters: Maximum period of interest',...
                'Analysis parameters: Spatial contrast vector',...
                '1st level model parameters: Design matrix',...
                '1st level model parameters: Contrasts',...
                '2nd level model parameters: Design matrix',...
                '2nd level model parameters: Contrasts'},...
            'SelectionMode', 'multiple',...
            'Name', 'spm_ROI. Setting project fields',...
            'ListSize',[350,370],...
            'PromptString', 'Select the desired parameter(s)');
        for n1=1:length(opts),
            spm_ROI_input(optsname{opts(n1)},[]);
        end
    end
elseif nargin<1 | isempty(SPM_ROIfile), % there is no current project defined
    ok=spm_ROI_input('init','open'); 
    if ~ok, 
        uiwait(errordlg('Failed to open an existing project. Attempting to create a new project','spm_ROI')); 
        spm_ROI_input('init','new'); 
    end;
end

if nargin>=1 & ~strcmp(lower(opt),'init'), % read project fields | set project fields
    [opt1,opt2]=strtok(opt,'.'); if ~isempty(opt2), opt2=opt2(2:end); end
    if ~isfield(SPM_ROI,opt1) | ~isfield(getfield(SPM_ROI,opt1),opt2), uiwait(errordlg(['Incorrect argument ',opt],'spm_ROI_input Error!')); return; end
    ans=getfield(getfield(SPM_ROI,opt1),opt2);

    if nargin>1 & ~isempty(force),
        SPM_ROI=setfield(SPM_ROI,opt1,setfield(getfield(SPM_ROI,opt1),opt2,force));

        % Special cases
        if strcmp(opt1,'model') & strcmp(opt2,'DesignMatrix'),
            SPM_ROI.private.SameSubjectDesign=(length(force)==1);
        elseif strcmp(opt1,'private') & strcmp(opt2,'Stage'), 
            SPM_ROIlogfile=[SPM_ROIfile(1:end-4),'.log'];
            fd=fopen(SPM_ROIlogfile,'a');
            fprintf(fd,'%s %s\n',date,force);
            fclose(fd);
        end
        save(SPM_ROIfile,'SPM_ROI');
        ans=getfield(getfield(SPM_ROI,opt1),opt2);
    elseif isempty(ans) | (nargin>1 & isempty(force)),
        switch(opt1)
        case 'files',
            [opt3,opt4]=strtok(opt2,'_'); if ~isempty(opt4), opt4=opt4(2:end); end

            switch(opt4)
            case 'subject'
                filename=spm_get(-inf,'',{'Select subject directories'});
                SPM_ROI.files.path_subject=filename; 
                
            case {'structural','hires'}
                path_subject=spm_ROI_input('files.path_subject'); nsubs=length(path_subject);
                filename=cell([nsubs,1]); pathname=filename;
                for nsub=1:nsubs,
                    filename{nsub}=spm_get(1,'img',['Select the ',opt4,' file for subject ',num2str(nsub)],path_subject{nsub});
                    if isempty(filename{nsub}), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                end
                [typeimage,ok]=listdlg(...
                    'ListString',...
                    {'PET','T1 MRI','T2 MRI','PD MRI','EPI','Transm','SPECT'},...
                    'SelectionMode', 'single',...
                    'Name', 'spm_ROI',...
                    'ListSize',[500,75],...
                    'PromptString', 'Select the image modality');
                SPM_ROI=setfield(SPM_ROI,'files',setfield(getfield(SPM_ROI,'files'),['type_',opt4],typeimage));
                SPM_ROI=setfield(SPM_ROI,'files',setfield(getfield(SPM_ROI,'files'),['name_',opt4],filename));
                
            case {'roi','roistruct','roimask'}
                path_subject=spm_ROI_input('files.path_subject'); nsubs=length(path_subject);
                filename1=cell([nsubs,1]); filename2=filename1;
                for nsub=1:nsubs,
                    filename1{nsub}=spm_get(1,'img',['Select the ROI mask for subject ',num2str(nsub)],path_subject{nsub});
                    pathname=fileparts(filename1{nsub});
                    filename2{nsub}=spm_get(1,'img',['Select the ROI structural for subject ',num2str(nsub)],pathname);
                    if isempty(filename1{nsub}) | isempty(filename2{nsub}), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                end
                SPM_ROI.files.name_roimask=filename1;
                SPM_ROI.files.name_roistruct=filename2;
                
            case {'roilabel'}
                filename=spm_get(1,'mat','Select ROI label file');
                SPM_ROI.files.name_roilabel=filename; 
                
            case {'experiment'}
                filename=spm_get(1,'mat','Select Experiment file');
                SPM_ROI.files.name_experiment=filename; 
                
            case {'roiproject'}
                path_subject=spm_ROI_input('files.path_subject'); nsubs=length(path_subject);
                filename1=cell([nsubs,1]);
                for nsub=1:nsubs,
                    filename1{nsub}=spm_get([],'spt',['Select the ASAP project for subject ',num2str(nsub)],path_subject{nsub});
                    pathname=fileparts(filename1{nsub});
                    if isempty(filename1{nsub}), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                end
                SPM_ROI.files.name_roiproject=filename1;
                
            case 'functional'
                path_subject=spm_ROI_input('files.path_subject'); nsubs=length(path_subject);
                clear filename
                for nsub=1:nsubs,
                    for nses=1:inf,
                        file=spm_get(inf,'img',['functional files subject # ',num2str(nsub),' session # ',num2str(nses)'],path_subject{nsub});
                        if ~isempty(file),
                            filename{nsub}{nses}=file; 
                        else 
                            if nses>1, break; else, uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end; 
                        end
                    end
                end
                SPM_ROI.files.name_functional= filename;
                
            otherwise,
                uiwait(errordlg(['Incorrect argument ',opt],'spm_ROI_input Error!')); return;
            end
            
        case 'model',

            switch(opt2)
            case 'RemoveGlobal'
                default=num2str(getfield(SPM_ROI.model,opt2));
                var1=inputdlg({'Remove global effects? (1/0)'},'model parameter definition',1,{default});
                if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                SPM_ROI.model=setfield(SPM_ROI.model,opt2, str2num(var1{1}));
                
            case 'Detrend'
                default=num2str(getfield(SPM_ROI.model,opt2));
                var1=inputdlg({'Detrend functional series? (1/0)'},'model parameter definition',1,{default});
                if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                SPM_ROI.model=setfield(SPM_ROI.model,opt2, str2num(var1{1})); 
                
            case 'SmoothFWHM'
                default=num2str(getfield(SPM_ROI.model,opt2));
                var1=inputdlg({'Intra-region smoothing FWHM? (mm)'},'model parameter definition',1,{default});
                if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                SPM_ROI.model=setfield(SPM_ROI.model,opt2, str2num(var1{1})); 
                
            case 'Whitening'
                default=num2str(getfield(SPM_ROI.model,opt2));
                var1=inputdlg({'Perform whitening? (1/0)'},'model parameter definition',1,{default});
                if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                SPM_ROI.model=setfield(SPM_ROI.model,opt2, str2num(var1{1}));
                
            case 'RepetitionTime'
                default=num2str(getfield(SPM_ROI.model,opt2));
                var1=inputdlg({'Repetition Time (RT)? (seconds)'},'model parameter definition',1,{default});
                if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                SPM_ROI.model=setfield(SPM_ROI.model,opt2, str2num(var1{1})); 
                
            case 'DataReductionType'
                default=upper(getfield(SPM_ROI.model,opt2));
                var1=inputdlg({'Data reduction type? (FFT/SVD)'},'model parameter definition',1,{default});
                if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                SPM_ROI.model=setfield(SPM_ROI.model,opt2, upper(var1{1})); 
                
            case 'DataReductionLevel'
                default=num2str(getfield(SPM_ROI.model,opt2));
                var1=inputdlg({'Data reduction level? (number of eigenvariates)'},'model parameter definition',1,{default});
                if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                SPM_ROI.model=setfield(SPM_ROI.model,opt2, str2num(var1{1})); 
                
            case 'MinPeriod'
                default=num2str(getfield(SPM_ROI.model,opt2));
                var1=inputdlg({'Minimum period of interest? (seconds)'},'model parameter definition',1,{default});
                if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                SPM_ROI.model=setfield(SPM_ROI.model,opt2, str2num(var1{1})); 
                
            case 'MaxPeriod'
                default=num2str(getfield(SPM_ROI.model,opt2));
                var1=inputdlg({'Maximum period of interest? (seconds)'},'model parameter definition',1,{default});
                if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                SPM_ROI.model=setfield(SPM_ROI.model,opt2, str2num(var1{1})); 
                
            case {'ContrastSpatialVector'}
                default=getfield(SPM_ROI.model,opt2);
                if isempty(default), default='1'; end
                drawnow; var1=inputdlg({'Spatial contrast vector (a formula on x, y, and z spatial coordinates)'},['Define spatial contrast'],1,{default});
                if isempty(var1{1}), uiwait(warndlg('Warning: Missing information','spm_ROI_input Error!')); return; end; 
                ContrastSpatialVector=var1{1};
                SPM_ROI.model.ContrastSpatialVector=ContrastSpatialVector;
                
            case 'DesignMatrix'
                load(spm_ROI_input('files.name_experiment'),'expt','-mat');
                nsubs=length(expt.subject);
                nmatrix=nsubs;
                X=cell([nsubs,1]);
                if ~isempty(name), nmatrix=-1;
                elseif nsubs>1,
                    var1=inputdlg({'Is there one design matrix for the whole experiment? (yes/no)'},'model parameter definition',1,{'yes'});
                    if isempty(var1{1}), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                    if strcmp(lower(var1{1}),'yes'), 
                        nmatrix=-1; 
                    else,
                        var1=inputdlg({'Is the subject-specific design matrix the same for all subject? (yes/no)'},'model parameter definition',1,{'yes'});
                        if isempty(var1{1}), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                        if ~strcmp(lower(var1{1}),'yes'), 
                            nmatrix=1;
                        end
                    end
                end
                default_path=pwd;
                for nsub=1:abs(nmatrix),
                    if ~isempty(name), filename=name;
                    else, filename=spm_get([0,1],'SPM.mat',['Subject ',num2str(nsub), 'design matrix file'],default_path); end
                    if isempty(filename),
                        TR=spm_roi_input('model.RepetitionTime');
                        files=spm_roi_input('files.name_functional');
                        nscan=zeros(1,length(files{nsub})); for n1=1:length(files{nsub}), nscan(n1)=size(files{nsub}{n1},1); end
                        SessOnes=[];
                        [data,Sess]=spm_fMRI_design(nscan,TR);
                        X{nsub}=data.X;
                    else
                        load(filename,'SPM');
                        X{nsub}=SPM.xX.X; %(:,data.xX.iC);
                        Sess=SPM.Sess;
                        SessOnes=SPM.xX.iB;
                        clear SPM;
                    end
                    
                    % To scale appropriately in order to get percent
                    % signal change [satra - July 12, 2004]
                    X{nsub} = X{nsub}./repmat(max(abs(X{nsub}),[],1),size(X{nsub},1),1);
                    default_path=fileparts(filename);
                end
		
                if nmatrix<nsubs, 
                    if nmatrix>0,
                        RemoveNonValid=[];
                        for nsub=2:nsubs, X{nsub}=X{1}; end; 
                    else, % Break full design matrix in subject-specific design matrices
                        nsess=zeros([1,nsubs]); 
                        clear sessvalid;
                        for nsub=1:nsubs, 
                            nsess(nsub)= ...
                                length(expt.subject(nsub).roidata);
                            count = 0;
                            for sessno = 1:nsess(nsub),
                                sessvalid{nsub}(sessno)=~all(~expt.subject(nsub).roidata(sessno).validfiles);
                                if sessvalid{nsub}(sessno),
                                    count = count+1;
                                end
                            end
                            sessvalid{nsub}=find(sessvalid{nsub});
                            nsess(nsub) = count;
                        end

                        if sum(nsess)~=length(Sess), uiwait(errordlg('Cannot make sense of design matrix: incorrect number of sessions','spm_ROI_input Error!')); return; end
                        Y=X{1}; X=cell([nsubs,1]);
                        %Sess=[Sess{:}];
                        cnsess=cumsum([0,nsess]);
                        countsess=1;
                        for nsub=1:nsubs, 
                            row=[Sess(cnsess(nsub)+1:cnsess(nsub+1)).row];
                            col=[Sess(cnsess(nsub)+1:cnsess(nsub+ ...
                                                            1)).col];
                            X{nsub}=Y(row,col);
                            spm2roidesign(nsub).spm=[col(:)];
                            spm2roidesign(nsub).roi=[1:length(col)]';
                            nrows=zeros(1,nsess(nsub));
                            for n1=1:nsess(nsub),
                                X{nsub}(Sess(cnsess(nsub)+n1).row-Sess(cnsess(nsub)+1).row(1)+1,end+1) = 1; % adds a column of ones
                                spm2roidesign(nsub).spm=cat(1,spm2roidesign(nsub).spm,SessOnes(countsess));
                                spm2roidesign(nsub).roi=cat(1,spm2roidesign(nsub).roi,size(X{nsub},2));
                                countsess=countsess+1;
                                nrows(n1)=length(Sess(cnsess(nsub)+n1).row);
                            end
                            cnrows=cumsum([0,nrows]);
                            if 0,
                               for n1=1:nsess(nsub),
                                   idxnonvalid=find(~expt.subject(nsub).roidata(sessvalid{nsub}(n1)).validfiles);
                                   %disp([nsub,n1,length(idxnonvalid)])
                                   if ~isempty(idxnonvalid),
		   		       X{nsub}(cnrows(n1)+idxnonvalid,:)=0;
                                       %X{nsub}(cnrows(n1)+idxnonvalid,size(X{nsub},2)+(1:length(idxnonvalid)))=eye(length(idxnonvalid)); % adds columns for nonvalid scans
                                   end
                               end
                            end
                        end
                    end
                end
                %SPM_ROI.model.MaxPeriod=expt.design.xX_K_HParam;
                %SPM_ROI.model.MinPeriod=2*expt.design.TR;
                %SPM_ROI.model.RepetitionTime=expt.design.TR;
                SPM_ROI.model=setfield(SPM_ROI.model,opt2, X); 
                SPM_ROI.private.SameSubjectDesign=(nmatrix==1);
                SPM_ROI.private.ValidSess=nsess;
                SPM_ROI.private.Sess=Sess;
		        SPM_ROI.private.SessOnes=SessOnes;
                SPM_ROI.private.spm2roidesign=spm2roidesign;
                
            case {'ContrastVector', 'ContrastName'}
                X=spm_ROI_input('model.DesignMatrix');
                load(spm_ROI_input('files.name_experiment'),'expt','-mat');
                nsubs=length(expt.subject);
                var1=inputdlg({'Load contrast from SPM? (yes/no)'},'model parameter definition',1,{'yes'});
                if isempty(var1{1}), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                if strcmp(lower(var1{1}),'yes'), 
                    filename=spm_get([0,1],'SPM.mat',['contrast file'],pwd);
                    load(filename,'SPM');
		    xCon = SPM.xCon;
		    Sess = SPM.Sess;
		    clear SPM;
                    nsess=zeros([1,nsubs]); 
		    %for nsub=1:nsubs, nsess(nsub)=length(expt.subject(nsub).roidata); end
		    for nsub=1:nsubs, 
			nsess(nsub)= ...
			    length(expt.subject(nsub).roidata);
			count = 0;
			for sessno = 1:nsess(nsub),
			    if all(expt.subject(nsub).roidata(sessno).validfiles)
				count = count+1; 
			    end
			end
			nsess(nsub) = count;
		    end
                    ncons=length(xCon);
                    cnsess=cumsum([0,nsess]);
                    for ncon=1:ncons,
                        for nsub=1:nsubs, 
                            ContrastVector{ncon,nsub}=xCon(ncon).c(cat(2,Sess(cnsess(nsub)+1:cnsess(nsub+1)).col));
                            ContrastVector{ncon,nsub}=[ContrastVector{ncon,nsub};zeros(size(X{nsub},2)-length(ContrastVector{ncon,nsub}),1)]';
                        end
                        ContrastName{ncon}=xCon(ncon).name;
                    end
                else,
                    x=spm_ROI_input('model.DesignMatrix'); nsubs=length(x);
                    designsame=spm_ROI_input('private.SameSubjectDesign');
                    neffects=cell([nsubs,1]); neffects{1}=size(x{1},2); for n1=2:length(x), neffects{n1}=size(x{n1},2); end
                    if designsame, nmatrix=1; else nmatrix=nsubs; end
                    default=max(1,size(SPM_ROI.model.ContrastVector,1));
                    var1=inputdlg({'Number of contrasts?'},'model parameter definition',1,{num2str(default)});
                    if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                    ncons=str2num(var1{1});
                    ContrastName=cell([ncons,1]); ContrastVector=cell([ncons,nsubs]);
                    hd=figure('numbertitle','off','name','spm_ROI design matrix','color',[.5,0,.5]); for n1=1:nmatrix, subplot(1,nmatrix,n1); imagesc(x{n1}); axis tight; set(gca,'xtick',1:size(x{n1},2)); grid on;  xlabel('Effects','color','y','fontweight','bold'); title(['Subject',num2str(n1)],'color','y','fontweight','bold'); if n1==1, ylabel('Scans','color','y','fontweight','bold'); end; end
                    for ncon=1:ncons,
                        quest=mat2cell([repmat('Effects contrast vector (one element for each effect) on subject ',[nmatrix,1]),num2str((1:nmatrix)')],ones(nmatrix,1));
                        default=cell([1,nmatrix]);
                        for n1=1:nmatrix,
                            if ~isempty(SPM_ROI.model.ContrastVector) & size(SPM_ROI.model.ContrastVector,1)>=ncon & size(SPM_ROI.model.ContrastVector,2)>=n1, 
                                if any(size(SPM_ROI.model.ContrastVector{ncon,n1})~=[1,neffects{n1}]) | all(SPM_ROI.model.ContrastVector{ncon,n1}==ones(size(SPM_ROI.model.ContrastVector{ncon,n1}))),
                                    default{n1}=['ones(1,',num2str(neffects{n1}),')']; 
                                else,
                                    default{n1}=num2str(SPM_ROI.model.ContrastVector{ncon,n1});
                                end
                            else
                                default{n1}=['ones(1,',num2str(neffects{n1}),')']; 
                            end
                        end
                        if isempty(SPM_ROI.model.ContrastName) | length(SPM_ROI.model.ContrastName)<ncon, defaultname=''; 
                        else, defaultname=SPM_ROI.model.ContrastName{ncon}; end
                        drawnow; var1=inputdlg({'Contrast name',quest{:}},['Define contrast # ',num2str(ncon)],1,{defaultname,default{1:nmatrix}});
                        for n1=1:nmatrix+1, if isempty(var1{n1}), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end; end
                        for n1=1:nmatrix, var1{1+n1}=str2num(var1{1+n1}); end
                        ContrastName{ncon}=var1{1};
                        [ContrastVector{ncon,:}]=deal(var1{2:end});
                    end
                    if ishandle(hd), close(hd); end
                end
                SPM_ROI.model.ContrastName=ContrastName;
                SPM_ROI.model.ContrastVector=ContrastVector;
                
            case 'Level2DesignMatrix'
                path_subject=spm_ROI_input('files.path_subject'); 
                nsubs=length(path_subject);
                defaultX=num2str(SPM_ROI.model.Level2DesignMatrix); 
                if isempty(defaultX), defaultX=num2str(ones(nsubs,1)); end
                var1=inputdlg({'2nd level design matrix (one row for each subject, one column for each effect)'},'spm_ROI',nsubs,{defaultX});
                if isempty(var1) | isempty(str2num(var1{1})), uiwait(warndlg('Warning: Missing information','spm_ROI_input Error!')); return; end
                SPM_ROI.model.Level2DesignMatrix=str2num(var1{1}); 
                
            case {'Level2ContrastVector', 'Level2ContrastName'}
                x=spm_ROI_input('model.Level2DesignMatrix');
                [nsubs,neffects]=size(x);
                default=max(1,length(SPM_ROI.model.Level2ContrastVector));
                var1=inputdlg({'Number of 2nd level contrasts?'},'model parameter definition',1,{num2str(default)});
                if isempty(var1), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end
                ncons=str2num(var1{1});
                ContrastName=cell([ncons,1]); ContrastVector=cell([ncons,1]);
                hd=figure('numbertitle','off','name','spm_ROI 2nd-level design matrix','color',[.5,0,.5]); imagesc(x); axis tight; set(gca,'xtick',1:neffects,'ytick',1:nsubs); grid on;  xlabel('2nd-level Effects','color','y','fontweight','bold'); ylabel('Subjects','color','y','fontweight','bold');
                for ncon=1:ncons,
                    if isempty(SPM_ROI.model.Level2ContrastName) | length(SPM_ROI.model.Level2ContrastName)<ncon, defaultname=''; 
                    else, defaultname=SPM_ROI.model.Level2ContrastName{ncon}; end
                    if isempty(SPM_ROI.model.Level2ContrastVector) | length(SPM_ROI.model.Level2ContrastVector)<ncon, default=num2str(ones(1,neffects));
                    else default=num2str(SPM_ROI.model.Level2ContrastVector{ncon}); end
                    drawnow; var1=inputdlg({'Contrast name','Contrast vector (one element for each 2nd-level effect)'},['Define contrast # ',num2str(ncon)],1,{defaultname,default});
                    for n1=1:2, if isempty(var1{n1}), uiwait(errordlg('Missing information','spm_ROI_input Error!')); return; end; end
                    ContrastName{ncon}=var1{1};
                    ContrastVector{ncon}=str2num(var1{2});
                end
                if ishandle(hd), close(hd); end
                SPM_ROI.model.Level2ContrastName=ContrastName;
                SPM_ROI.model.Level2ContrastVector=ContrastVector;
                
            otherwise,
                uiwait(errordlg(['Incorrect argument ',opt],'spm_ROI_input Error!')); return;
            end
            
        case 'private',
        otherwise,
            uiwait(errordlg(['Incorrect argument ',opt],'spm_ROI_input Error!')); return;
        end

        save(SPM_ROIfile,'SPM_ROI');
        ans=getfield(getfield(SPM_ROI,opt1),opt2);
    end
end


