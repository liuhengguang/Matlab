%% Second Algorithm to find a correlation between the Accelerometer and the
% PPG signals to reduce noise
clear all
close all
clc

addpath(genpath('../functions'));
addpath(genpath('../signals'));
%% Data an signals definition

sample = load('Pierre_BVP.csv');
%signal = sample(:,2)';
PPG = downsample(sample(3:end)',2);
sample = load('Pierre_ACC.csv');
ACC = sample(3:end,:)';
Accel_X = ACC(1,:);
Accel_Y = ACC(2,:);
Accel_Z = ACC(3,:);

Fs = 64/2; % sampling frequency
Time = linspace(0,length(PPG)/Fs, length(PPG));

%% ACCEL
T = 60*60;
timeThour = 1:Fs*T:length(PPG); 


figure,
subplot(211)
plot(Time(timeThour(1):timeThour(2))/60/60,PPG(timeThour(1):timeThour(2)))
axis('tight')
grid on
xlabel('time (sec)')
ylabel('Amplitude')
title('signal')
subplot(212)
plot(Time(timeThour(1):timeThour(2))/60/60,Accel_X(timeThour(1):timeThour(2)))
hold all
plot(Time(timeThour(1):timeThour(2))/60/60,Accel_Y(timeThour(1):timeThour(2)))
plot(Time(timeThour(1):timeThour(2))/60/60,Accel_Z(timeThour(1):timeThour(2)))
axis('tight')
grid on
legend('acc X', 'acc Y', 'acc Z')
xlabel('time (sec)')
ylabel('Amplitude')
title('Accelerometre')

%% PSD signal and Accelerometer

[pAccel_X, wX] = periodogram(Accel_X(timeThour(1):timeThour(2)));
[pAccel_Y, wY] = periodogram(Accel_Y(timeThour(1):timeThour(2)));
[pAccel_Z, wZ] = periodogram(Accel_Z(timeThour(1):timeThour(2)));
[pPPG_A13, wPPG] = periodogram(PPG(timeThour(1):timeThour(2)));

figure, 
subplot(211)
plot(wX,10*log10(pAccel_X))
hold on 
plot(wY,10*log10(pAccel_Y))
plot(wZ,10*log10(pAccel_Z))
grid on 
axis('tight')
subplot(212)
plot(wPPG,10*log10(pPPG_A13))
grid on 
axis('tight')

[corrM, lagsShort] = xcorr(PPG(timeThour(1):timeThour(2)),Accel_Y(timeThour(1):timeThour(2)), 'unbiased');
conv_PPG_ACC = conv(PPG(timeThour(1):timeThour(2)),Accel_Y(timeThour(1):timeThour(2)));
%% Results
timeinter = timeThour(1):timeThour(2);

timecorr = [-flip(timeinter) 0 timeinter];
timecorr = timecorr(2:end-1);


figure,
subplot(311)
plot(Time(timeThour(1):timeThour(2))/60,PPG(timeThour(1):timeThour(2)))
axis('tight')
grid on
subplot(312)
plot(Time(timeThour(1):timeThour(2))/60,Accel_Y(timeThour(1):timeThour(2)))
axis('tight')
grid on
subplot(313)
plot(corrM)
axis('tight')
grid on