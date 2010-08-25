function val = getdata(htrans,varargin)
% GETDATA Allows public access of certain member variables

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /ROITOOLBOX/tools/@uitransfer/getdata.m 2     12/16/02 6:12p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

% check validity of the object
if ~htrans.validui,
    error('Invalid object handle');
end;

switch lower(varargin{1}),
case 'points',
    htrans = get(htrans.line,'userdata');
    val = htrans.pts;
otherwise,
    error('Invalid parameter');
end;