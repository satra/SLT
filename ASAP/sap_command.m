function varargout = sap_command(varargin)
% SAP_COMMAND Command line, argment based interface to launching ASAPP or
% making it perform different tasks

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/ASAPP.m 4     10/08/02 2:36p Satra $

% $NoKeywords: $

% Setup globals
global DEBUG

switch lower(varargin{1}),
    case 'preprocess',
        % varargin{2} = T1-weighted analyze image name before
        % normalization. The preprocessing performs normalization of this
        % file.
        %varargout(1) = {sap_preprocess_single(varargin{2})};
        varargout(1) = {roi_asap_preprocess(varargin{2})};
    case 'initialize',
        ASAPP('init');
    case 'create',
        % varargin{2} = T1-weighted processed analyze image name (corr_*.img)
        varargout(1) = {sap_createproj(varargin{2})};
    case 'open',
        % varargin{2} = *.spt ASAPP project file returned by preprocess or
        % create
        ASAPP(varargin{2});
    case 'createmask',
        % This function is available within ASAPP but in case you want
        % to create the mask separately as a batch process this will allow
        % you to do so.
        % varargin{2} = *.spt ASAPP project file returned by preprocess or
        % create
        varargout(1) = {sap_createROImask(varargin{2},varargin{3})};
    case 'getmaskname',
        % This function just returns the name of the mask without actually
        % creating it.
        varargout(1) = {sap_createROImask(varargin{2},[],1)};
    case 'getlabels',
        % This function will return a cell array called Labels
        % The second field will contain indices to those elements which
        % contain labels
        [Labels,valid] = sap_getLabels;
        varargout(1) = {Labels};
        varargout(2) = {valid};
    otherwise,
        error('sap_command: Unknown command');
end;
