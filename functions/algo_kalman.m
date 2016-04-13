function [ind_R, pulse_T, pulse ] = algo_kalman( signal, Fs, Tpulse )
% This function calculate the heart rate by using the kalman filter
% signal: signal which is studied
% Fs: sampling Frequency 
% Tpulse: step of the pulse is calculated
% ind_R: index of the peacks
% pulse_min: number of peacks by a Tpulse
% pulse: heart rate

%% Data definition
time = (0:length(signal)-1)/Fs;
time_min = 1:floor(Fs*60):length(signal);

%% Kalman Filter
signal_noisefree = [];
for t = 1:length(time_min)-1

    x = signal(time_min(t):time_min(t+1));
    n = length(x);
    Order = 55;
    
    % Estimation of the noise variance using Yule Walker equation
    
    Corr = xcorr(x,n,'unbiased');
    Rx = toeplitz(Corr(n+1:end-1));
    %AR parameters estimation
    R = Rx(1:Order,1:Order);
    Rv = Rx(1,2:Order+1);

    AR_est = -(R)^(-1)*transpose(Rv);

    %Variance estimation
    v_bbgc = sum(Rx(1,1:Order+1).*[1 transpose(AR_est)]);


    % Kalman 
    Phi_k =  eye(Order);
    
    R = v_bbgc;
    
    X_0_0 = ones(1,Order);
    
    alpha = 10^5;
    P_0_0 = alpha*eye(Order);
    
    [ X_correct, M] = kalman( Phi_k, R, x ,Order, X_0_0, P_0_0);
    
    signal_inter = conv(x,M(end,:));
    signal_inter = signal_inter(Order:end);
    signal_noisefree = [signal_noisefree signal_inter];
end

%% smoothing of the signal

windowSize = 15;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
signal_filt = filtfilt(b,a,signal_noisefree);

b = [2,1,0,-1,-2];
a = 1;
filter_size = length(b);
signal_filter = filter(b,a,signal_filt);

[ R, ind_R ] = detection_peack( signal_filter, Fs, time, filter_size, 0.7, 0.2);

%% Pulse Detection
[ pulse_T ] = pulse_ppg( length(signal), Tpulse, ind_R, Fs);
[ pulse ] = heart_rate(ind_R);

%% plot

figure,
subplot(211)
plot(time/60,signal-mean(signal))
subplot(212)
plot(time(1:length(signal_filter))/60,signal_filter)
hold on
plot(ind_R/60, R,'x','linewidth',2),
legend('kalman','Peack')
xlabel('time in min')
ylabel('signal')
title('Peack detection of a PPG using Kalman filter')
end

