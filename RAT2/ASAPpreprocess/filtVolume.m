function filtVol = filtVolume(volume);
% FILTVOLUME    This function runs a median filter on the volume;

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/preprocess.1/filtVolume.m 2     10/08/02 2:36p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

filtVol = zeros(size(volume));

% Essentialy fills all the holes in the brain by filling in two
% orthogonal dimensions

hproc = uiwaitbar('Filtering: Dimension 2');
for i=1:size(volume,2),
    filtVol(:,i,:)=medfilt2(squeeze(volume(:,i,:)));
    uiwaitbar(i/size(volume,2),hproc);
end;

uiwaitbar(0,hproc,'title','Filtering: Dimension 3');
for i=1:size(filtVol,3),
    filtVol(:,:,i)=medfilt2(squeeze(filtVol(:,:,i)));
    uiwaitbar(i/size(filtVol,3),hproc);
end;
delete(hproc);