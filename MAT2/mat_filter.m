function data = mat_filter(data,fs)
%MAT_FILTER(data)
%MAT_FILTER low pass filters the data
%
%Ideally needs to have modifiable cutoff frequency, sensitivity

%load('mat_kwlp','kwlp');
[b,a] = butter(9,40/(fs/2));
data = filtfilt(b,a,data')';