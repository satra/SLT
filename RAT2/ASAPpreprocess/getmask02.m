function brainmask = getmask02(braindatafile,wmmaskfile,extmaskfile);
% GETMASK02 Determines a crude mask that includes most of gray matter, but excludes
%   skull

% Satrajit Ghosh, SpeechLab, Boston University. (c)2001
% $Header: /SpeechLabToolkit/ASAP/preprocess.1/getmask02.m 2     10/08/02 2:37p Satra $

% $NoKeywords: $

% Setup globals
global RELEASE

V = spm_vol(braindatafile);
braindata = spm_read_vols(V);
%load(braindatafile);
load(wmmaskfile);

% Determine the maximum of the white matter region
%   need to test mean
wmVOI = braindata.*double(wmmask);
max_wm = mean(wmVOI(find(wmVOI(:))))
clear wmVOI;

% Generate an image where all of white matter is constant and higher in intensity
% than its nearest neighbors
load(extmaskfile);
brainmask = braindata.*double(extMask).*(1-double(wmmask))+max_wm*double(wmmask);
clear extMask braindata;

% The following loop essentially thresholds the brainmask at successively lower 
% thresholds. It works on the assumption that if one was to go out in a radial
% direction from the white matter mass, the intensity drops an then starts 
% increasing towards the skull and then drops again for background. Since one
% can assume the CSF surrounds the brain almost completely and is lower in intensity
% than gray matter, by thresholding, ones separates the white matter+gray matter
% volume from surrounding skull fat and CSF. 
% The iteration step consists of determining the pieces that remain after thresholding
% and then selecting the largest one and considering everything else to be noise.
noisemask = uint8((brainmask>=max_wm)-double(wmmask));
brainmask = (1-double(noisemask)).*brainmask;
threshold = 0.5;
increment = 0.5;
%threshold = 0.5:increment:max_wm;
%threshold = max_wm-logspace(log10(max_wm),log10(0.5),100);
threshold = linspace(0,max_wm,100);
N = length(threshold);

fig = figure('doublebuffer','on');
axh = subplot(3,1,3);
% iterate while threshold reaches the white matter maximum
hproc = uiwaitbar(fig,axh,'getting brain mask');
for i=1:N,
    [L,num] = bwlabeln(uint8(brainmask>=(max_wm-threshold(i))));
    L = uint16(L);
    if num>1
        Ltmp = L(:);
        h = hist(double(Ltmp(find(Ltmp))),num);
        [maxval,ind] = max(h);
        noisemask = uint8(double(L>0)-double(L==ind));
        brainmask = (1-double(noisemask)).*brainmask;
        figure(fig);
subplot(321);imagesc(squeeze(brainmask(:,109,:)));
subplot(322);imagesc(squeeze(brainmask(:,:,91)));
subplot(323);imagesc(squeeze(brainmask(91,:,:)));
subplot(324);imagesc(squeeze(sum(noisemask,2)));
drawnow;
    end;
    uiwaitbar(i/N,hproc,'title',['getting brain mask: ' num2str(threshold(i))]);  
end;
delete(hproc);
close(fig);

brainmask = uint8(brainmask>0);

% subplot(221);imagesc(squeeze(f(:,109,:)));
% subplot(222);imagesc(squeeze(f(:,:,91)));
% subplot(223);imagesc(squeeze(f(91,:,:)));
% subplot(224);imagesc(squeeze(sum(noisemask,2)));
% drawnow;

