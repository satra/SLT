function varargout = rave_input( varargin )
%RAVE_INPUT Set/Get rave_struct and its fields (see rave_defaults.m)
%   RAVE_INPUT('rave_struct',rave_defaults) Initializes the function
%
%   RAVE_INPUT('field_name',field_val) Sets the field_name field of
%   rave_struct to field_val
%
%   RAVE_INPUT('field_name',[]) Will prompt to set the value of the 
%   field.
%   
%   field_val = RAVE_INPUT('field_name') Will return the current value 
%   of the field
%
%   See also RAVE_DEFAULTS, RAVE_COMMAND

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /RAVE/rave_input.m 1     12/13/02 5:48p Satra $

% $NoKeywords: $

% rave persistent data structure
persistent rave_struct rave_fields;

input_param = lower(varargin{1});
values = varargin(2:end);

if isempty(rave_struct) & ~strcmp(input_param,'rave_struct'),
    disp('rave_input: rave structure has not been initialized');
    return;
end;

switch (input_param),
    case 'rave_struct',
        if nargin==2 & ~isempty(values),
            if isstruct(values{1}),
                rave_struct = values{1};
                rave_fields = fieldnames(rave_struct);
            else,
                disp('rave_input: rave parameters not a struct');
            end;
        else,
            %[varargout{1}] = rave_struct;
        end;
    otherwise,
        idx = find(strcmp(rave_fields,input_param));
        if ~isempty(idx),
            if nargin==1,
                [varargout{1}] = rave_struct.(input_param);
            elseif ~isempty(values{1}),
                rave_struct.(input_param) = values{1};
            else
                rave_struct.(input_param) = rave_getvalue(input_param,rave_struct.(input_param));
            end;
        else,
            disp(['rave_input: rave field[',input_param,'] does not exist.']);
        end;
end;

function fieldvalue = rave_getvalue(field_name,oldval)
disp(['rave_input: rave_getvalue not implemented yet. Retaining old ' ...
      'value of ',field_name]);
fieldvalue = oldval;

