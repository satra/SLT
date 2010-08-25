function spm_ROI_bch_ASAP(varargin);
% spm_ROI_bch_ASAP 
% Interface with ASAP
%
% spm_ROI_bch_ASAP(opts)
%

% 10/02
% alfnie@bu.edu

if ~nargin, return; end

path_subject=spm_ROI_input('files.path_subject'); 
nsubs=length(path_subject); 
namestruct=spm_ROI_input('files.name_structural');
for n1=1:nsubs, [path_struct{n1},name_struct{n1},ext_struct{n1}]=fileparts(namestruct{n1}); end
spm_ROI_input('private.Stage',[mfilename,' {',varargin{1},'}']);

switch(lower(varargin{1})),
case 'preprocess',
    for n1=1:nsubs,
        name_roiproject{n1}=sap_command('Preprocess', namestruct{n1});
    end
    spm_ROI_input('files.name_roiproject',name_roiproject);
case 'asap',
    name_roiproject=spm_ROI_input('files.name_roiproject');
    if isempty(name_roiproject),
        uiwait(errordlg('Run Preprocessing first','spm_ROI!')); 
        return;
    else
        [idxsubject,ok]=listdlg(...
            'ListString',...
            path_subject,...
            'SelectionMode', 'single',...
            'Name', 'spm_ROI',...
            'ListSize',[500,75],...
            'PromptString', 'Select the subject directory');
        sap_command('Open', name_roiproject{idxsubject});
    end 
case 'mask',
    name_roiproject=spm_ROI_input('files.name_roiproject');
    if isempty(name_roiproject),
        uiwait(errordlg('Run Preprocessing first','spm_ROI!')); 
        return;
    else
        for n1=1:nsubs,
            name_roistruct{n1}=fullfile(path_struct{n1},[name_struct{n1},'.img']);
            name_roimask{n1}=sap_command('CreateMask',name_roiproject{n1},fullfile(path_struct{n1},['corr_n',name_struct{n1},'.img']));
        end
        Label=sap_command('getLabels');
        
        [path,name,ext]=fileparts(spm_ROI_input('init','null')); 
        name_roilabel=fullfile(path,[name,'.mat']);
        save(name_roilabel,'Label','-mat');
        spm_ROI_input('files.name_roistruct',name_roistruct);
        spm_ROI_input('files.name_roimask',name_roimask);
        spm_ROI_input('files.name_roilabel',name_roilabel);
    end
end


