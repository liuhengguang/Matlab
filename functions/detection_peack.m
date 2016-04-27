function [ R, ind_R ] = detection_peack( signal, Fs, time, type, thresholdmax, thresholdfilt)
% This functions find the peack of a ppg signal by a step of 10 seconds
% signal: signal which is studied
% Fs: sampling frequency
% time: vector corespond of time of the signal in second
% type: size of filter if the signal was filter
% thresholdmax: threshold if the signal was filter 
% thresholdfilt: threshold for the peack detection

if size(signal,1)==1
    signal = signal';
end
   
ind_R = [];
R = [];

threshold = signal>0;
signal = signal.*threshold;

time_10S = 1:floor(Fs*10):length(signal);

for p = 1:length(time_10S)-1
    x = signal(time_10S(p):time_10S(p+1));
    [R_inter, ind_R_inter] = findpeaks(x,Fs,'MinPeakDistance',60/200);
    
    mean_R_inter = mean(R_inter);
    median_R_inter = median(R_inter);
    threshold = R_inter>thresholdfilt*(mean_R_inter+median_R_inter)/2;
    
    R_inter = R_inter.*threshold;
    ind_R_inter = ind_R_inter.*threshold;
    R_inter = R_inter(R_inter~=0);
    ind_R_inter = ind_R_inter(ind_R_inter~=0);
    
    ind_R_inter = ind_R_inter+time(time_10S(p));
    ind_R = horzcat(ind_R,ind_R_inter');
    R = horzcat(R,R_inter');

end

if type ~= 0
    if ind_R(1)<type
        ind_R = ind_R(2:end);
        R = R(2:end);
    end
    
    R_diff = diff(R);
    
    threshold = thresholdmax*max(abs(R_diff));
    
    for k=1:length(R_diff)
        if abs(R_diff(k))>= threshold
            R(k+1)=0;
            ind_R(k+1)=0;
            
            if R_diff(k)>0
                R(k)=0;
                ind_R(k)=0;
            end
        end
    end
    
    R = R(R~=0);
    ind_R = ind_R(ind_R~=0);
end

end

