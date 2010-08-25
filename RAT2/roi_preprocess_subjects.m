function expt = roi_preprocess_subjects(expt,sid,type,FLAG)
% EXPT = ROI_PREPROCESS_SUBJECTS(EXPT) preprocesses each
% subject specified in the EXPT structure to perform realignment,
% coregsitration, normalization (both affine and full) and
% smoothing (in case of full normalization). It returns the updated
% experiment structure containing information about preprocessed
% files. The data is created in subfolders called 'affine' and
% 'full' at the location of the original data.
%
% EXPT = ROI_PREPROCESS_SUBJECTS(EXPT,SID) allows one to specify
% which subjects' should be preprocessed. If SID is left empty all
% subjects are preprocessed.
%
% EXPT = ROI_PREPROCESS_SUBJECTS(EXPT,SID,TYPE) specifies whether
% the normalization is only 'affine' or 'full' (nonlinear) or
% 'both' (default).
%
% EXPT = ROI_PREPROCESS_SUBJECTS(EXPT,SID,TYPE,FLAG) controls which
% step of the process to execute. FLAG is a 6 element boolean
% vector:[doRealign,doCoregister,doANormalize,doFnormalize,doSmooth,
% doFSegment].
% Each of these flags determine whether the process should be
% performed (1) and/or whether the file pointers should be updated
% (1/0).
% Note: FSegment creates a rendering file for each subject, such
% that the random fx level1 results are plotted on each subject.
%
% See also: ROI_REALIGN_SUBJECT, ROI_COREGISTER_SUBJECT,
% ROI_AFFINENORMALIZE_SUBJECT, ROI_FULLNORMALIZE_SUBJECT,
% ROI_SMOOTH_SUBJECT, @EXPERIMENT, @SESSION, EXPT_SETUP_DEMO

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Changes 17.Jan.2004
% Added generation of rendering mat file for use with randomfx
% analysis. See doFSegment.

if nargin<2 | isempty(sid),
    sid = 1:length(expt.subject);
end;
sid = sid(:)';
if nargin<3,
    type = 'both';
end;
if nargin<4,
    FLAG = [1 1 1 1 1 1];
end;

doRealign       = 1 & FLAG(1);
doCoregister    = 1 & FLAG(2);
doANormalize    = 1 & FLAG(3);
doFNormalize    = 1 & FLAG(4);
doSmoothing     = 1 & FLAG(5);
doFSegment      = 1 & FLAG(6);

roi_write_log('roi_preprocess_subjects: Starting preprocessing');
roi_write_log(['roi_preprocess_subjects: subjects ',num2str(sid)]);

for subjno=sid,
    P = {};
    roi_write_log(['roi_preprocess_subjects: Processing subject ',num2str(subjno)]);
    for nsess=1:length(expt.subject(subjno).functional),
        P{nsess,1} = expt.subject(subjno).functional(nsess).filenames;
    end;

    PG = expt.subject(subjno).structural.filenames;
    PF = expt.subject(subjno).hires.filenames;

    % perform regular preprocessing
    if doRealign,
        roi_write_log(['roi_preprocess_subjects: Realigning subject ',num2str(subjno)]);
        roi_realign_subject(P);
    end

    % Get the realignment parameters filename
    for nsess=1:length(expt.subject(subjno).functional),
        [pth,nm,xt] = fileparts(expt.subject(subjno).functional(nsess).filenames(1,:));
        expt.subject(subjno).functional(nsess).realigntxt = spm_get('files',pth,sprintf(['rp_%s.txt'],nm));
    end;

    P = char(P);
    if doCoregister,
        roi_write_log(['roi_preprocess_subjects: Coregistering subject ',num2str(subjno)]);
        roi_coregister_subject(PG,PF,P);
    end;

    % perform affine normalization and writing
    if strcmp(type,'affine') | strcmp(type,'both'),
        if doANormalize,
            roi_write_log(['roi_preprocess_subjects: Affine Transforming subject ',num2str(subjno)]);
            roi_affinenormalize_subject(PG,strvcat(PF,P));
        end;

        % move the written files over to the affine directory
        % create the directory if it does not exist
        for nsess=1:length(expt.subject(subjno).structural),
            PP = '';
            for i=1:size(expt.subject(subjno).structural(nsess).filenames,1),
                [pth,nam,ext] = fileparts(expt.subject(subjno).structural(nsess).filenames(i,:));
                files2move = fullfile(pth,['w',nam,'.*']);
                PP(i,:)       = fullfile(pth,'affine',['w' nam ext]);
                if doANormalize,
                    try
                        movefile(files2move,fullfile(pth,'affine'));
                    catch
                        roi_write_log(['Can''t move structural.' ...
                            ' Probably exists at destination']);
                    end
                end;
            end;
            expt.subject(subjno).structural(nsess).pp_affine = PP;
        end;
        for nsess=1:length(expt.subject(subjno).hires),
            PP = '';
            for i=1:size(expt.subject(subjno).hires(nsess).filenames,1),
                [pth,nam,ext] = fileparts(expt.subject(subjno).hires(nsess).filenames(i,:));
                files2move = fullfile(pth,['w',nam,'.*']);
                PP(i,:)       = fullfile(pth,'affine',['w' nam ext]);
                if doANormalize,
                    movefile(files2move,fullfile(pth,'affine'));
                end;
            end;
            expt.subject(subjno).hires(nsess).pp_affine = PP;
        end;
        for nsess=1:length(expt.subject(subjno).functional),
            PP = '';
            for i=1:size(expt.subject(subjno).functional(nsess).filenames,1),
                [pth,nam,ext] = fileparts(expt.subject(subjno).functional(nsess).filenames(i,:));
                files2move = fullfile(pth,['w',nam,'.*']);
                PP(i,:)       = fullfile(pth,'affine',['w' nam ext]);
                if doANormalize,
                    movefile(files2move,fullfile(pth,'affine'));
                end;
            end;
            expt.subject(subjno).functional(nsess).pp_affine = PP;
            if doANormalize
            %%[TODO] Calculate globals here
            end
        end;
    end;

    % perform full normalization writing and smoothing
    if strcmp(type,'full') | strcmp(type,'both'),
        if doFNormalize,
            roi_write_log(['roi_preprocess_subjects: Full Transforming subject ',num2str(subjno)]);
            roi_fullnormalize_subject(PG,strvcat(PF,P));
        end;

        % move the written files over to the full directory
        % create the directory if it does not exist
        for nsess=1:length(expt.subject(subjno).structural),
            PP = '';
            for i=1:size(expt.subject(subjno).structural(nsess).filenames,1),
                [pth,nam,ext] = fileparts(expt.subject(subjno).structural(nsess).filenames(i,:));
                files2move = fullfile(pth,['w',nam,'.*']);
                PP(i,:)       = fullfile(pth,'full',['w' nam ext]);
                if doFNormalize,
                    try
                        movefile(files2move,fullfile(pth,'full'));
                    catch
                        roi_write_log(['Can''t move structural.' ...
                            ' Probably exists at destination']);
                    end
                end;
            end;
            expt.subject(subjno).structural(nsess).pp_full = PP;
            if doFSegment,
                roi_segment(PP);
            end
        end;
        for nsess=1:length(expt.subject(subjno).hires),
            PP = '';
            for i=1:size(expt.subject(subjno).hires(nsess).filenames,1),
                [pth,nam,ext] = fileparts(expt.subject(subjno).hires(nsess).filenames(i,:));
                files2move = fullfile(pth,['w',nam,'.*']);
                PP(i,:)       = fullfile(pth,'full',['w' nam ext]);
                if doFNormalize,
                    movefile(files2move,fullfile(pth,'full'));
                end;
            end;
            expt.subject(subjno).hires(nsess).pp_full = PP;
        end;
        for nsess=1:length(expt.subject(subjno).functional),
            PP = '';
            for i=1:size(expt.subject(subjno).functional(nsess).filenames,1),
                [pth,nam,ext] = fileparts(expt.subject(subjno).functional(nsess).filenames(i,:));
                files2move = fullfile(pth,['w',nam,'.*']);
                PP(i,:)       = fullfile(pth,'full',['w' nam ext]);
                if doFNormalize,
                    movefile(files2move,fullfile(pth,'full'));
                end;
            end;
        end;

        PF = '';
        for i=1:size(P,1),
            [pth,nam,ext] = fileparts(P(i,:));
            PF(i,:)       = fullfile(pth,'full',['w' nam ext]);
        end;

        if doSmoothing,
            roi_write_log(['roi_preprocess_subjects: Smoothing' ...
                ' subject ',num2str(subjno)]);
            if ~isempty(expt.design.roiSmoothFWHM)
                if isnumeric(expt.design.roiSmoothFWHM),
                    roi_smooth_subject(PF,expt.design.roiSmoothFWHM);
                else,
                    roi_smooth_subject(PF,str2num(expt.design.roiSmoothFWHM));
                end
            else,
                roi_smooth_subject(PF);
            end;
        end;

        for nsess=1:length(expt.subject(subjno).functional),
            PP = '';
            for i=1:size(expt.subject(subjno).functional(nsess).filenames,1),
                [pth,nam,ext] = fileparts(expt.subject(subjno).functional(nsess).filenames(i,:));
                PP(i,:)       = fullfile(pth,'full',['pp_w' nam ext]);
                if doFNormalize,
                    delete(fullfile(pth,'full',['w' nam '.*']));
                end;
            end;
            expt.subject(subjno).functional(nsess).pp_full = PP;
            if doFNormalize,
            %%[TODO] Calculate globals here
            end
        end;
    end;
    roi_write_log(['roi_preprocess_subjects: Finished processing subject ',num2str(subjno)]);
end;
roi_write_log('roi_preprocess_subjects: Finished preprocessing');
