%% Algorithm for finding the respiratory rate in a PPG signal 
clear all
close all

addpath(genpath('../functions'));
addpath(genpath('../signals'));

%% Signal and data definition

load('Gauthier_25_04_PPG.mat')
signal = Gauthier_25_04_PPG';
Fs = floor(100.51); % sampling frequency
time = (0:length(signal)-1)/Fs;

figure, plot(time/60,signal)
axis('tight')
xlabel('time (min)')
ylabel('Amplitude')
title('signal')

%% Bandpass Filter

Wn = 2*[0.1 0.3]/Fs;
[b1,a1] = butter(3,Wn,'bandpass');
P = 100;
b2 = 1/P*ones(1,P);
a2 = 1;

signal_filt1 = filter(b1,a1,signal);
signal_filt2 = filter(b2,a2,signal_filt1);

figure, plot(time/60,signal_filt1)
hold on
plot(time/60,signal_filt2)
grid on
legend('1','2')
axis('tight')
xlabel('time (min)')
ylabel('Amplitude')
title('signal filter')

%% Peaks detection 
time_20sec = 1:Fs*20:length(signal);
R = [];
I = [];

for k = 1:length(time_20sec)-1
    x = signal_filt2(time_20sec(k):time_20sec(k+1));
    [Rinter, Iinter]=findpeaks(x,Fs,'MinPeakDistance',2,'MinPeakHeight',1.5*mean(x));
    Iinter = Iinter+time(time_20sec(k));
    I = [I Iinter];
    R = [R Rinter];
end

figure, plot(time/60,signal_filt2)
hold all
plot(I/60,R,'gx','LineWidth',2)
grid on
axis('tight')
xlabel('time (min)')
ylabel('Amplitude')
title('signal filter')

time_min = 1:Fs*60:length(signal);
respiratory_rate = zeros(1,length(time_min)-1);

for k =1:length(time_min)-1
    for p= 1:length(I)
        if I(p)*Fs>=time_min(k) && I(p)*Fs<=time_min(k+1)
            respiratory_rate(k) = respiratory_rate(k)+1;
        end
    end
end

%% Results
figure, plot(time_min(1:end-1)/Fs/60,respiratory_rate)
grid on
axis('tight')
xlabel('time (min)')
ylabel('Amplitude')
title('Respiratory Rate')


