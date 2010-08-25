% Script to test speed of compiled SPM files
spm_defaults;

% Tests defined
tests = {'Simple read','Linear resample', 'Sinc resample', ...
	  'NaN linear resample', 'Smooth'};

% Make test image
dim = [128 128 128];
img = randn(dim);
V    = struct(...
    'fname','test.img',...
    'dim',[dim spm_type('float')],...
    'mat',eye(4),...
    'pinfo',[1 0 0]',...
    'descrip','test image');
V = spm_write_vol(V, img);

% Read to load cache
img = spm_read_vols(V);

% write with NaNs
V2 = V;
V2.fname = 'nan_test.img';
img(img < 3.5) = NaN;
V2 = spm_write_vol(V2, img);

disp('Hit Enter to start tests');
pause;
% Start tests
t = [];

disp('Performing simple read');
% simple read
tic
img = spm_read_vols(V);
t = [t toc];

% resampling
startp = 2;
grain = 1;
dims = V.dim(1:3) - 2;
[X Y Z] = ndgrid(startp:grain:dims(1), ...
		  startp:grain:dims(2), ...
		  startp:grain:dims(3));
X = X+0.5; Y = Y+0.5; Z = Z + 0.5;

disp('Performing linear sampling');
tic
p = spm_sample_vol(V, X, Y, Z, 1); % trilinear
t = [t toc];

disp('Performing sinc sampling');
tic 
p = spm_sample_vol(V, X, Y, Z, -8); % sinc
t = [t toc];

disp('Performing linear NaN sampling');
tic 
p = spm_sample_vol(V2, X, Y, Z, 1); % trilinear, NaN
t = [t toc];

disp('Performing smoothing');
% smoothing
tic
spm_smooth(V, 'sm_test.img', 8);
t = [t toc];

% report
for i = 1:length(tests)
  fprintf('%20s: %5.2f\n', tests{i}, t(i));
end

