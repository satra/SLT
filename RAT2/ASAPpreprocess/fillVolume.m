function [fillVol,extVol] = fillVolume(volume,bExtend,dim);
% FILLVOLUME    This function fills all internal holes in a volume
%   In addition, it creates an extended volume if the parameter bExtend is nonzero

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/preprocess.1/fillVolume.m 2     10/08/02 2:36p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

if nargin<2,bExtend = 0;end;
if nargin<3,dim = [2 3];end;

volume = uint8(volume);

fillVol = uint8(zeros(size(volume)));
if bExtend,
    extVol = uint8(zeros(size(volume)));
end;

% Essentialy fills all the holes in the brain by filling in two
% orthogonal dimensions
hproc = uiwaitbar('Filling holes: Dimension 2');
if any(dim==2),
    for i=1:size(volume,2),
        fillVol(:,i,:)=bwfill(squeeze(volume(:,i,:)),'holes');
        if bExtend,
            extVol(:,i,:) = bwmorph(squeeze(fillVol(:,i,:)),'dilate',17);
        end
        uiwaitbar(i/size(volume,2),hproc);
    end;
end;
if any(dim==3),
    uiwaitbar(0,hproc,'title','Filling holes: Dimension 3');
    for i=1:size(fillVol,3),
        fillVol(:,:,i)=bwfill(squeeze(fillVol(:,:,i)),'holes');
        if bExtend,
            extVol(:,:,i) = squeeze(extVol(:,:,i)) | bwmorph(squeeze(fillVol(:,:,i)),'dilate',17);
        end;
        uiwaitbar(i/size(fillVol,3),hproc);
    end;
end;
delete(hproc);