clrscr;

% To plot timecourses for specific image 'voxels'
load ms_data_results_2124.mat ImageGridAmp
load('E:\00_PILOT\RAW\mriSurfaces.mat');

%voxels = [1421,2773,2334,1688,2200];
%regions = {'Visual Cortex','Angular Gyrus','Right Auditory Cortex','MTG','MT?'};
%voxels = [35847,38296,28016,27669,35579,27674,19274,21284,24112,21020,24087,16976];
%regions = {'L.Auditory','L.Post.Auditory','L.MTG','L.BA37','L.AngG','L.VenAngG','L.InfTG','L.InfTGa',...
%        'L.OTJ','LVis','LVisLatDors','LVisLatVen'};

voxels = [28924,45398,31341,31159,37787,38876];
regions = {'lV1','lAngG','lTOJ','lpInfG','lSTG','lHeschl'};

time = [0:399];


vData = ones(length(ImageGridAmp),1)*32;
figure;
for i=1:length(voxels),
    s = subplot(ceil(length(voxels)/2),2,i);
    nb = neighbors(brain_schizo, voxels(i));
    for k=1:6,
        nb = [nb; neighbors(brain_schizo, nb(k))];
    end;
    vData(nb) = 60;
    timecourse = mean(ImageGridAmp(nb,:),1);
    plot(time+1,timecourse,'r');
    hold on;
    plot(time+1,ImageGridAmp(nb,:),'b');
    lim = max([abs(min(timecourse)) max(timecourse)]);
    set(s,'YLim',[-lim lim],'XLim',[-100 600]);
    hold on;
    %plot([0 500],[mean(timecourse) mean(timecourse)],'r--');
    legend(regions{i},0);
end;

%subplot(2,1,1);
figure;
colormap(gray);
showVertexValueDirect(brain_schizo,vData);
view(-160,10);
axis tight;
%colorbar;