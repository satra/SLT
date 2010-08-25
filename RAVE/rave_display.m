function varargout = rave_display( input_args )
%RAVE_DISPLAY Summary of this function goes here
%  Detailed explanation goes here
if rave_check,
    switch rave_input('show_act')
        case 0,
            rave_display_noact;
        case 1,
            [varargout{1:nargout}] = rave_display_standard;
        case 2,
            rave_display_roi('uniform');
        case 3,
            rave_display_roi('center');
        case 4,
            rave_display_roi('sphere');
        otherwise,
    end;
end;
