function [allVerts] = showTimeCourses(surfstruct)

resultsFiles = {'2676_results_dGoodR_noFilter_MNE_MEG_1206.mat',...
                '2676_results_dAmbig_noFilter_MNE_MEG_1206.mat',...
                '2676_results_dGoodL_noFilter_MNE_MEG_1206.mat'};
% ,...
%                 '2676_data_dAmbig_noFilter_results',...
%                 '2676_data_dGoodL_noFilter_results'};
        
roiVertices = [9936,9079,16069];
roiNames = {'rHeschl','rSMG','rSTS'};
colors = {[1 0 0],[0 1 0],[0 0 1]};
diameter = 4;
allVerts = [];

for i=1:length(resultsFiles),
    load(resultsFiles{i},'ImageGridAmp');
    figure;
    for j=1:length(roiVertices),
        nv = st_nNeighbors(surfstruct,roiVertices(j),diameter);
        [u,s,v] = svd(double(ImageGridAmp(nv,:)'));
        hold on;
        plot(u(:,1),'Color',colors{j});
    end;
    allVerts = [allVerts; nv];
    legend(roiNames{1},roiNames{2},roiNames{3});
end;
    
v = zeros(length(surfstruct.vertices),1)+32;
v(allVerts) = 64;

figure;
showVertexValueDirect(surfstruct,v);
