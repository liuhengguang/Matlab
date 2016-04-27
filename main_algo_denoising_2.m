%% Algorithm 2: Using the Kalman filter for denoising of PPG 
clear all
close all
clc

addpath(genpath('./functions'));
addpath(genpath('./signals'));

%% Signal and data definitions

signal = load('perfect_ppg.mat');
signal = signal.perfect_ppg;
time = load('time_perfect_ppg.mat');
time = time.time_perfect_ppg;
time = (time-time(1))*10^(-3);

Fs = 128; % sampling frequency

time_min = 1:floor(Fs*60):length(signal);

% Generate original signal and a noisy version adding
% a standard Gaussian white noise.
snr = -20;
EB_N0 = 1;
v_bbgc = 10^(-snr(EB_N0)/10);
signal_noise = signal+v_bbgc*randn(1,length(signal))';

figure, plot(time,signal_noise)
hold all
plot(time,signal), axis([0 120 -1000 4000])
xlabel('time (sec)')
ylabel('signal')
legend('signal','signal noise')
%% Kalman Filter
signal_noisefree = [];
for t = 1:length(time_min)-1
    x = signal_noise(time_min(t):time_min(t+1));
    n = length(x);
    Order = 55;
    
    Phi_k =  eye(Order);
    
    R = v_bbgc;
    
    X_0_0 = ones(1,Order);
    
    alpha = 10^5;
    P_0_0 = alpha*eye(Order);
    
    [ X_correct, M] = kalman( Phi_k, R, x ,Order, X_0_0, P_0_0);
    
    signal_inter = conv(x,M(end,:));
    signal_inter = signal_inter(Order:end);
    signal_noisefree = [signal_noisefree; signal_inter];
end

%% smoothing of the signal

windowSize = 15;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
signal_filt = filtfilt(b,a,signal_noisefree);

figure
plot(signal)
hold all
plot(signal_noisefree)
plot(signal_filt)
legend('s','k','f')

xd = signal_filt;
pulse_min = zeros(1,length(time_min)-1);
ind_R = [];
R = [];

b = [2,1,0,-1,-2];
a = 1;
filter_size = length(b);
signal_filter = filter([2,1,0,-1,-2],1,xd);

threshold = signal_filter>0;
signal_filter = signal_filter.*threshold;

time_10S = 1:floor(Fs*10):length(xd);

for p = 1:length(time_10S)-1
    x = signal_filter(time_10S(p):time_10S(p+1));
    [R_inter, ind_R_inter] = findpeaks(x,Fs,'MinPeakDistance',60/200);
    
    mean_R_inter = mean(R_inter);
    median_R_inter = median(R_inter);
    threshold = R_inter>0.2*(mean_R_inter+median_R_inter)/2;
    
    R_inter = R_inter.*threshold;
    ind_R_inter = ind_R_inter.*threshold;
    R_inter = R_inter(R_inter~=0);
    ind_R_inter = ind_R_inter(ind_R_inter~=0);
    
    ind_R_inter = ind_R_inter+time(time_10S(p));
    
    ind_R = [ind_R ;ind_R_inter];
    R = [R; R_inter];
end

if ind_R(1)<filter_size
    ind_R = ind_R(2:end);
    R = R(2:end);
end

R_diff = diff(R);

threshold = 0.7*max(abs(R_diff));

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

%% Pulse Detection
for k = 1:length(time_min)-1
    for p = 1:length(ind_R)
        if ind_R(p)*Fs>time_min(k) && ind_R(p)*Fs<time_min(k+1)
            pulse_min(k) = pulse_min(k)+1;
        end
    end
end

[ pulse ] = heart_rate(ind_R);

figure,
plot(time,signal-mean(signal))
hold on
plot((0:length(signal_filter)-1)/Fs,signal_filter),
plot(ind_R, R,'gx','linewidth',2),
legend('signal norm','signal filter', 'Peack Detection')
xlabel('time in sec')
ylabel('signal')
title('Peack detection of a PPG')

figure, plot(pulse)
title('heart rate')
