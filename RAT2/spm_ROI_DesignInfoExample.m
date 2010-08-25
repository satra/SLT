function X=CreateDesignMatrix;

% spm_ROI_DesignInfoExample
% This is an example MATLAB function defining 
% a design matrix for a block design experiment.
% Modify this example as needed. The output 
% design matrix (variable X) should have one
% column for each effect and one row for each scan.
% Other effects (such as motion correction estimates,
% linear trends, and global scaling are automatically
% generated if the correponding options are selected
% in the spm_ROI gui so you do not need to include them)
%

blocklength=15;                             % block length (scans)
block=sin(linspace(0,pi,blocklength))';     % half-sine block
silence=zeros(blocklength,1);

X=[ block   ,   silence ; 
    silence ,   silence ;
    silence ,   block ;
    silence ,   silence ;
    block   ,   silence ; 
    silence ,   silence ;
    silence ,   block ;
    silence ,   silence ;
    block   ,   silence ; 
    silence ,   silence ;
    silence ,   block ;
    silence ,   silence ];
        
