function spm_progress_bar(action,arg1,arg2,arg3,arg4)
% Display a 'Progress Bar'
% FORMAT spm_progress_bar('Init',height,xlabel,ylabel)
% Initialises the bar in the 'Interactive' window.
%
% FORMAT spm_progress_bar('Set',value)
% Sets the height of the bar itself.
%
% FORMAT spm_progress_bar('Clear')
% Clears the 'Interactive' window.
%
%-----------------------------------------------------------------------
% @(#)spm_progress_bar.m	2.1 John Ashburner 99/05/17

persistent hproc hlim
if nargin == 0,
	spm_progress_bar('Init');
    return;
end;

switch(action),
case 'Init',
    if ~isempty(hproc),
        delete(hproc);
    end;
    if nargin<3,
        hproc = uiwaitbar('Unknown Process');
    elseif nargin<4,
        hproc = uiwaitbar([arg2]);
    else,
        hproc = uiwaitbar([arg2 ':' arg3]);
    end;
    if nargin<2,
        hlim = 1;
    else,
        hlim = arg1;
    end;
case 'Set',
    uiwaitbar(arg1/hlim,hproc);
case 'Clear',
    delete(hproc);
    hproc = [];
end;
