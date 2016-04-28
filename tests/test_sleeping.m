% Algorithm for finding the sleep time of a personn who wore an
% accelerometer
clear all
close all
clc

addpath(genpath('../functions'));
addpath(genpath('../signals'));
%% Data an signals definition

load('Pierre_26_04_Timestamp.mat')
load('Pierre_26_04_ACCEL.mat')

Timestamp = Pierre_26_04_Timestamp;
ACCEL = Pierre_26_04_ACCEL;
TimeBegin = 12*60*60+49*60+59;
Timestamp = (Timestamp-Timestamp(1))*10^(-3)+TimeBegin;
Fs = 100.51; % sampling frequency



%% Accelerometer studying
T =30;
timeTsec = 1:floor(Fs*T):size(ACCEL,1);
timeTsec(end+1) = size(ACCEL,1)-1;
diff_ACCEL = abs(diff(ACCEL));

figure, 
subplot(211)
plot(Timestamp/60/60,ACCEL); 
grid on; axis('tight'),
title('Accelerometer')
xlabel('time in hour')
ylabel('Amplitude')
subplot(212)
plot(Timestamp(1:end-1)/60/60,diff_ACCEL); 
grid on; axis('tight'),
title('Accelerometer Derivated')
xlabel('time in hour')
ylabel('Amplitude')

mean_ACCEL = zeros(length(timeTsec)-1,3);
max_ACCEL = zeros(length(timeTsec)-1,3);
MM_ACCEL = zeros(length(timeTsec)-1,3);

for k =1:length(timeTsec)-1
    mean_ACCEL(k,:) = mean(diff_ACCEL(timeTsec(k):timeTsec(k+1),:));
    max_ACCEL(k,:) = max(diff_ACCEL(timeTsec(k):timeTsec(k+1),:));
    MM_ACCEL(k,:) = (max(ACCEL(timeTsec(k):timeTsec(k+1),:))-min(ACCEL(timeTsec(k):timeTsec(k+1),:)));
end

figure, 
subplot(311)
plot(Timestamp/60/60,ACCEL); 
grid on; axis('tight'),
title('Accelerometer')
xlabel('time in hour')
ylabel('Amplitude')
subplot(312)
plot((timeTsec(1:end-2)/Fs+TimeBegin)/60/60,abs(diff(10*log((mean_ACCEL)))));
grid on; axis('tight'),
title('Mean Accelerometer Derivated Log')
xlabel('time in hour')
ylabel('Amplitude')
subplot(313)
plot((timeTsec(1:end-2)/Fs+TimeBegin)/60/60,abs(diff(10*log((max_ACCEL)))));
grid on; axis('tight'),
title('Max Accelerometer Derivated Log')
xlabel('time in hour')
ylabel('Amplitude')


%% Sleep Detection
log_mean_ACCEL = abs(diff(10*log(mean_ACCEL)));
time2min = 1:floor(Fs*60*2):size(ACCEL,1);
time2min(end+1) = size(ACCEL,1);
sleep = zeros(1,length(time2min)-1);

for k = 1:length(time2min)-1
    T_end = 0;
    for p = 1:length(timeTsec)-2
        if timeTsec(p)>=time2min(k) && timeTsec(p)<=time2min(k+1)
            if T_end == 0
                T_begin = p;
                T_end = p;
            else
                T_end = p;
            end
        end
    end
    
    if T_end~=0
        x = log_mean_ACCEL(T_begin:T_end,:);
        x_diff = max(x)-min(x);
        x_mean = mean(x);
        if max(x_mean)<=0.45 && max(x_diff)<0.7
            sleep(k)=1;
        end
    end
end

%% Smoothing of the sleep detection

count0 = 0;
count1 = 0;
Nb_cut = 4;
sleep2 = zeros(1,length(sleep));

for k = 2:length(sleep)
    
    if sleep(k) == 1 
        count0 = count0+1;
        count1 = 0;
    end
    
    if sleep(k)==0
        count1 = count1 +1;
        if count0 ~= 0
            count0 = count0+1;
        end
    end
        
    if count0 ~= 0 && count1 > Nb_cut
        if count0>3+Nb_cut
           sleep2(k+1-count0+Nb_cut:k)=ones(1,count0-Nb_cut);
        end
        count0 = 0;
    end
end

%% Results
figure, 
subplot(311)
plot(Timestamp/60/60,ACCEL); 
grid on; axis('tight'),
title('Accelerometer')
xlabel('time in hour')
ylabel('Amplitude')
subplot(312)
plot((time2min(1:end-1)/Fs+TimeBegin)/60/60,sleep); 
grid on
xlim([(time2min(1)/Fs+TimeBegin)/60/60 (time2min(end-1)/Fs+TimeBegin)/60/60])
ylim([-0.3 1.3])
title('sleep')
xlabel('time in hour')
ylabel('Amplitude')
subplot(313)
plot((time2min(1:end-1)/Fs+TimeBegin)/60/60,sleep2); 
grid on
xlim([(time2min(1)/Fs+TimeBegin)/60/60 (time2min(end-1)/Fs+TimeBegin)/60/60])
ylim([-0.3 1.3])
title('sleep 2')
xlabel('time in hour')
ylabel('Amplitude')
