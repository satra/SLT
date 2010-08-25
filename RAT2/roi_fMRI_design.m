function roi_fMRI_design(expt,sid,designonly)
% ROI_FMRI_DESIGN(EXPT) creates an initial SPM structure based on
% the information provided in the EXPT object and uses the
% spm_fMRI_design function.
%
% ROI_FMRI_DESIGN(EXPT,SID) allows one to specify which subjects to
% use. If left empty, it creates a design matrix for all subjects
% in the EXPT structure.
%
% RI_FMRI_DESIGN(EXPT,SID,DESIGNONLY) adds a boolean flag
% DESIGNONLY (default 0) that determines whether just a design
% matrix is created or whether scaling globals are computed.
%
% See also: ROI_FIXEDFX_SUBJECTS

% Satrajit Ghosh, SpeechLab, Boston University. (c) 2003
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

spm_defaults;

% Use all subjects if no subject index is provided
if nargin<2 | isempty(sid),
    sid = 1:length(expt.subject);
end;
if nargin<3,
    designonly = 0;
end;

sid = sid(:)';

% Specify design as an accumulation for each subject to be analyzed;
%===========================================================================
SPM.nscan   = [];
SPM.xY.P    = '';
scount = 0;
design = expt.design;
condname = design.condnames;

for nsubj = sid,
    for nsess=1:length(expt.subject(nsubj).functional),

        valididx = ...
            find(expt.subject(nsubj).functional(nsess).validfiles);

        % Satra first pass at bug fix [not complete]
        if strcmp(expt.design.xBF_name,'Finite Impulse Response')
            allonsets = 1:length(expt.subject(nsubj).functional(nsess).validfiles);
            allonsets = allonsets(:)-1;
            % [TODO] Need to deal with time specification for event
            % related studies. The following will work for block
            % and event triggerred studies
            %if strcmp(lower(expt.design.xBF_UNITS),'secs'),
            %    allonsets = allonsets*expt.design.TR;
            %end
%             invalidonsets = unique(setdiff(allonsets, ...
%                 unique(allonsets(valididx))));
            invalidonsets = setdiff(allonsets,allonsets(valididx));
            % Remap the onsets that were defined in the object
            onsetmap = cumsum(expt.subject(nsubj).functional(nsess).validfiles)-1;
        else,
            invalidonsets = [];
            onsetmap = [];
        end
        % [BUG Found: Jay/Satra 1/7/2004] noncontiguous validfiles
        % can cause issues.

        if ~isempty(valididx),

            % Remap onsets depending on units
            % invalidonsets = (valididx==0).*[1:length(valididx)

            scount = scount+1;
            % number of scans and session, e.g. [128 128 128] for 3 sessions
            %---------------------------------------------------------------------------
            SPM.nscan          = [SPM.nscan,length(valididx)];

            onsets   = expt.subject(nsubj).functional(nsess).onsets;
            durations= expt.subject(nsubj).functional(nsess).durations;

            % Trial specification: Onsets, duration (UNITS) and parameters for modulation
            %---------------------------------------------------------------------------
            eliminate_idx = [];
            for j=1:length(condname),
                SPM.Sess(scount).U(j).name      = condname(j);
                [ons,onsidx] = setdiff(onsets{j}(:),invalidonsets);
                if ~isempty(ons),
                    SPM.Sess(scount).U(j).ons       = ons;
                    if ~isempty(onsetmap)
                        SPM.Sess(scount).U(j).ons       = onsetmap(ons+1);
                    end
                    if length(durations{j}(:))>1,
                        SPM.Sess(scount).U(j).dur       = durations{j}(onsidx);
                    else
                        SPM.Sess(scount).U(j).dur       = durations{j}(:);
                    end
                else,
                  eliminate_idx = [eliminate_idx;j];
                end
                SPM.Sess(scount).U(j).P(1).name = 'none';
            end;
            SPM.Sess(scount).U(eliminate_idx) = [];

            usercovs        = ...
                expt.subject(nsubj).functional(nsess).covariates;
            % Load realignmnet parameters from the text file
            realignparam    = ...
                spm_load(expt.subject(nsubj).functional(nsess).realigntxt);
            if isempty(usercovs),
                usercovs = zeros(size(realignparam,1),0);
            end;

            % design (user specified covariates)
            %---------------------------------------------------------------------------
            if expt.design.detrend,
                SPM.Sess(scount).C.C    = [usercovs(valididx,:),realignparam(valididx,:)]; % [n x c double]% covariates
                % add detrending covariate
                SPM.Sess(scount).C.C    = [SPM.Sess(scount).C.C,linspace(-1,1,size(SPM.Sess(scount).C.C,1))'];
            else,
                SPM.Sess(scount).C.C    = [usercovs(valididx,:),realignparam(valididx,:)];          % [n x c double] covariates
            end;

            for nreg= 1:size(SPM.Sess(scount).C.C,2),
                SPM.Sess(scount).C.name{1,nreg} = sprintf('regressor %d',nreg);
            end

            % specify data: matrix of filenames and TR
            %===========================================================================
            filenames = expt.subject(nsubj).functional(nsess).pp_full;

            %%%%  ALFONSO SAYS AAAAAARRRRRRRGGGGGHHHHHHH %%%%%
            %filenames =
            %expt.subject(nsubj).functional(nsess).pp_affine;

            if isempty(SPM.xY.P),
                SPM.xY.P           = filenames(valididx,:);
            else,
                SPM.xY.P           = char([cellstr(SPM.xY.P);cellstr(filenames(valididx,:))]);
            end;
        end;
    end;
end;

% specify data: session/subject independent
% basis functions and timing parameters
%---------------------------------------------------------------------------
% OPTIONS:'hrf'
%         'hrf (with time derivative)'
%         'hrf (with time and dispersion derivatives)'
%         'Fourier set'
%         'Fourier set (Hanning)'
%         'Gamma functions'
%         'Finite Impulse Response'
%---------------------------------------------------------------------------
SPM.xBF.name       = expt.design.xBF_name;
SPM.xBF.length     = expt.design.xBF_length;
SPM.xBF.order      = expt.design.xBF_order;
SPM.xBF.T          = expt.design.xBF_T;
SPM.xBF.T0         = expt.design.xBF_T0;
SPM.xBF.UNITS      = expt.design.xBF_UNITS;
SPM.xBF.Volterra   = expt.design.xBF_Volterra;

%===========================================================================
% global normalization: OPTINS:'Scaling'|'None'
%---------------------------------------------------------------------------
SPM.xGX.iGXcalc    = expt.design.xGX_iGXcalc;

% low frequency confound: high-pass cutoff (secs) [Inf = no filtering]
%---------------------------------------------------------------------------
SPM.xX.K.HParam    = expt.design.xX_K_HParam;

% intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
%-----------------------------------------------------------------------
if ~isempty(expt.design.xVi_form),
    SPM.xVi.form       = expt.design.xVi_form;
end;

% Repetition Time/Volume Collection time
%-----------------------------------------
SPM.xY.RT          = expt.design.TR;  % seconds


% Configure design matrix
%===========================================================================
if designonly,
    SPM = spm_fMRI_design(SPM);
else,
    SPM = spm_fmri_spm_ui(SPM);
end

