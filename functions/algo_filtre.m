function [ ind_R1, pulse_T1, pulse1, ind_R2, pulse_T2, pulse2 ] = algo_filtre( signal, Fs, Tpulse )
% This function calculate the heart rate by using a buuter and cheby filter
% signal: signal which is studied
% Fs: sampling Frequency 
% Tpulse: step of the pulse is calculated
% ind_R1: index of the butter peacks
% pulse_min1: number of the butter peacks by a Tpulse
% pulse1: heart rate whith butter filter
% ind_R2: index of the cheby peacks
% pulse_min2: number of the cheby peacks by a Tpulse
% pulse2: heart rate whith cheby filter
time = (0:length(signal)-1)/Fs;
%% Bandpass filtering
Wn = 2*[0.5 3.5]/Fs;
[b1,a1] = butter(5,Wn,'bandpass');
Wn = 2*[0.5 4.5]/Fs;
[b2,a2] = cheby2(5,20,Wn,'bandpass');
signal_filt1 = filtfilt(b1,a1,signal);
signal_filt2 = filtfilt(b2,a2,signal);

figure,
pwelch(signal,[],[],[],Fs)
figure,
pwelch(signal_filt1,[],[],[],Fs)
figure,
pwelch(signal_filt2,[],[],[],Fs)
%% Detection of local peak per 10 sec

[ R1, ind_R1 ] = detection_peack( signal_filt1', Fs, time', 0, 0, 0.2);
[ R2, ind_R2 ] = detection_peack( signal_filt2', Fs, time', 0, 0, 0.2);

%% Pulse Detection
[ pulse_T1 ] = pulse_ppg( length(signal), Tpulse, ind_R1, Fs);
[ pulse_T2 ] = pulse_ppg( length(signal), Tpulse, ind_R2, Fs);
[ pulse1 ] = heart_rate(ind_R1);
[ pulse2 ] = heart_rate(ind_R2);


figure
plot(time/60,signal-mean(signal))
hold all
plot(time/60, signal_filt1)
plot(ind_R1/60,R1,'x','linewidth',2)
plot(time/60, signal_filt2)
plot(ind_R2/60,R2,'x','linewidth',2)
axis('tight')
legend('signal','butter','Peack butter','cheby2','Peack cheby2')
xlabel('time in min')
ylabel('signal')
title('Peack detection of a PPG by using butter and cheby2 filter')
end

