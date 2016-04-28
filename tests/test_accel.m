%% Algorithm to find a correlation between the Accelerometer and the PPG signals to reduce noise
clear all
close all
clc

addpath(genpath('../functions'));
addpath(genpath('../signals'));
%% Data an signals definition

load('Accel_X.mat')
load('Accel_Y.mat')
load('Accel_Z.mat')
load('PPG_A13.mat')
load('Timestamp.mat')

Time = (Timestamp-Timestamp(1))*10^(-3);
Fs = 128; % sampling frequencies
N = length(PPG_A13);
nyquistFreq = Fs/2;
NFFT = 2^nextpow2(N);

figure,
subplot(211)
plot(Time,PPG_A13)
axis('tight')
grid on
xlabel('time (sec)')
ylabel('Amplitude')
title('signal')
subplot(212)
plot(Time,Accel_X)
hold all
plot(Time,Accel_Y)
plot(Time,Accel_Z)
axis('tight')
grid on
legend('acc X', 'acc Y', 'acc Z')
xlabel('time (sec)')
ylabel('Amplitude')
title('Accelerometre')

%% Look to a correlation of the signal

% run accel signal through low pass filter
nyquistFreqHR = Fs/2;
WnHR = 5/nyquistFreqHR;
filt1 = fir1(100, WnHR);
Accel_X = filter(filt1, 1, Accel_X);
Accel_Y = filter(filt1, 1, Accel_Y);
Accel_Z = filter(filt1, 1, Accel_Z);
PPG_A13 = filter(filt1, 1, PPG_A13);


Accel_X0 = Accel_X-mean(Accel_X);
Accel_Y0 = Accel_Y-mean(Accel_Y);
Accel_Z0 = Accel_Z-mean(Accel_Z);
PPG_A130 = PPG_A13-mean(PPG_A13);

Xmean = mean(diff(Accel_X0));
Ymean = mean(diff(Accel_Y0));
Zmean = mean(diff(Accel_Z0));

T = 5;
[M, I] = max([Xmean Ymean Zmean]);
maxCorr = 0;
acc = [Accel_X0 Accel_Y0 Accel_Z0];
accel = acc(:,I);
timeTsec = 1:Fs*T:length(PPG_A13);
timeTsec(end) = length(PPG_A13);
Xout = [];
order = T;
l = order+1; % filter length
lambda = 1; % RLS forgetting factor
invcov = T*eye(l);
RLSfilt = adaptfilt.rls(l, lambda, invcov);
mean_accel = [];
for k=1:length(timeTsec)-1
    if k == length(timeTsec)-1
        accelShort = accel(timeTsec(k):timeTsec(k+1));
        x = PPG_A130(timeTsec(k):timeTsec(k+1));
    else
        accelShort = accel(timeTsec(k):timeTsec(k+1)-1);
        x = PPG_A130(timeTsec(k):timeTsec(k+1)-1);
    end
    [corrM, lagsShort] = xcorr(accelShort,x, 'coeff');
    corrM = corrM((length(accelShort)):end);
    lagsShort = lagsShort((length(accelShort)):end);
    [corr, i] = max(corrM);
    
    if corr>0.6
        % get the RLS filter
        [outRLSshort, errorRLS] = filter(RLSfilt, accelShort, x);
        Xout = [Xout; outRLSshort];
    else
        Xout = [Xout; x];
    end
end

figure,
subplot(211)
plot(Time,PPG_A13)
axis('tight')
grid on
xlabel('time (sec)')
ylabel('Amplitude')
title('Signal')
subplot(212)
plot(Time,Xout)
axis('tight')
grid on
xlabel('time (sec)')
ylabel('Amplitude')
title('Decoralated Signal')

%% Band-pass filter and pulse obtention
Wn = 2*[0.5 3]/Fs;
[b,a] = cheby2(3,30,Wn,'bandpass');
signal_filt = filtfilt(b,a,Xout);

[ R, ind_R ] = detection_peack( signal_filt, Fs, Time, 0, 0, 0.1);
[ pulse ] = heart_rate(ind_R);
T = 5;
[ pulse_smooth ] = heart_rate_smooth(ind_R, Fs, length(Xout), T);
%% Results
figure, plot(Time, signal_filt)
hold all
plot(ind_R,R,'x')
axis('tight')
grid on
legend('filter signal', 'Peaks')
xlabel('time (sec)')
ylabel('Amplitude')
title('Detection PPG')

timeTsec = 1:T*Fs:length(Xout);
figure, plot(timeTsec(1:end-1)/Fs,pulse_smooth)
axis('tight')
grid on
xlabel('time (sec)')
ylabel('Amplitude')
title('Heart rate')