studyName = 'rala';
doFlags = [0 1];

options.Method = 'meg_os';         % Can be 'meg_sphere', 'meg_os' (overlapping spheres),
                                    % or 'meg_bem' (Boundary Element Method)

myBEM.EnvelopeNames{1}.TessFile = 'subject.2676_tesselation.mat';
myBEM.EnvelopeNames{1}.TessName = 'Cortex';
myBEM.EnvelopeNames{2}.TessFile = 'subject.2676_tesselation.mat';
myBEM.EnvelopeNames{2}.TessName = 'Skull';
myBEM.basis = 'linear';
myBEM.Test = 'Galerkin';
myBEM.NFaceMax = 10000;

%options.BEM = myBEM;

options.HeadModelName = strcat(studyName,options.Method);   % Arbitrary string name for model
options.HeadModelFile = '2676_headmodel.mat';   % Name of file to save head model
options.ImageGridFile = '2676_imagegrid.bin';   % Name of file to save cortical lead field
options.ImageGridBlockSize = 1024;              % Size of processing blocks (this controls 
                                                % memory usage)
options.Verbose = 0;                            % 0 or 1

options.Scalp = struct('FileName','subject.2676_tesselation.mat','iGrid',2);

options.ChannelFile = 'C:\Data\RaLa_MEG\Analysis.2676\rala_channel.mat';

options.Cortex = struct('FileName','subject.2676_tesselation.mat','iGrid',1);


if (doFlags(1)) 
    [G,options] = bst_headmodeler(options);
end;

sourceOptions.DataTypes = 1;                     % 1 for MEG, 2 for EEG, 3 for Fusion

sourceOptions.DataFile = {'2676_data_dGoodR.mat','2676_data_dAmbig.mat',...
                          '2676_data_dGoodL.mat'};
                  
sourceOptions.TimeSegment = [-200 500];
sourceOptions.GridLoc = options.Cortex.FileName;
sourceOptions.iGrid = options.Cortex.iGrid;
sourceOptions.HeadModelFile = '2676_headmodelSurfGrid_CD.mat';
sourceOptions.Method = 'Minimum-Norm Imaging';
sourceOptions.Tikhonov = 10;
sourceOptions.FFNormalization = 1;
sourceOptions.Rank = 15;

if (doFlags(2))
    [Results,myoptions] = bst_sourceimaging(sourceOptions);
end;