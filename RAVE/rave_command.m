function varargout = rave_command( varargin )
%RAVE_COMMAND Summary of this function goes here
%  Detailed explanation goes here

command = varargin{1};
args = varargin(2:end);

switch(command),
    case 'init',
        rave_input('rave_struct',rave_defaults);
    case 'save',
    case 'open',
    case 'display',
        [varargout{1:nargout}] = rave_display;
    case 'update',
    case 'close',
    otherwise,
end

function rave_parse_command(varargin)
