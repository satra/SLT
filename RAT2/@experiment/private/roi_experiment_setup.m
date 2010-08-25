function varargout = roi_experiment_setup(varargin)

varargout{1} = experiment;
if nargin<1,
    disp('No input arguments');
    return;
end;

experiment = lower(varargin{1});
values = varargin(2:end);

switch (input_param),
    case 'experiment',
        if isempty(experiment),
            experiment = roi_expt_struct_defaults;
        elseif ~isempty(values) & values(1)==1
            disp('reinitializing experiment');
            experiment = roi_expt_struct_defaults;
        end;
    case 'add_subject',
        if isempty(experiment.subject),
            experiment.subject = roi_subject_struct_defaults;
        else,
            experiment.subject(length(experiment.subject)+1,1) = roi_subject_struct_defaults;
        end;
        experiment = roi_experiment_setup('subject',length(experiment.subject),values);
    case 'remove_subject',
    case 'subject',
        id = values(1);
        experiment.subject(id) = setfields(experiment.subject(id),values(2:end));
    otherwise,
        try
            experiment.(input_param) = values;
        catch
            disp(['Unknown parameter: ',input_param]);
        end;
end;

varargout{1} = experiment;

function x = setfields(x,params)

for i=1:2:length(params),
    x.(params(i)) = params(i)+1;
end;