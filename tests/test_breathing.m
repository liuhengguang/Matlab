%% Algorithm for finding the the respiratory rate in a PPG signal 
clear all
close all

addpath(genpath('../functions'));
addpath(genpath('../signals'));

%% Signal and data definition

sample = load('Pierre_BVP.csv');
signal = sample(3:end)';
Fs = 64; % sampling frequency
time = (0:length(signal)-1)/Fs;


figure, plot(time/60,signal)
axis('tight')
xlabel('time (min)')
ylabel('Amplitude')
title('signal')

%% Bandpass Filter

Wn = 2*[0.1 0.4]/Fs;
[b1,a1] = butter(3,Wn,'bandpass');

signal_filt = filter(b1,a1,signal);

figure, plot(time/60,signal_filt)
grid on
axis('tight')
xlabel('time (sec)')
ylabel('Amplitude')
title('signal filter')
%% 
time_10sec = 1:Fs*20:length(signal);
R = [];
I = [];

for k = 1:length(time_10sec)-1
    x = signal_filt(time_10sec(k):time_10sec(k+1));
    [Rinter, Iinter]=findpeaks(x,Fs,'MinPeakDistance',1.5,'MinPeakHeight',1.5*mean(x));
    Iinter = Iinter+time(time_10sec(k));
    I = [I Iinter];
    R = [R Rinter];
end

figure, plot(time/60,signal_filt)
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

respiratory_rate;
figure, plot(time_min(1:end-1)/Fs/60,respiratory_rate)
grid on
axis('tight')
xlabel('time (min)')
ylabel('Amplitude')
title('Respiratory Rate')