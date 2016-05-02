clear all
close all
clc

addpath(genpath('../functions'));
addpath(genpath('../signals'));
%% Signal and Data definitions

load('Gauthier_26_04_Timestamp.mat')
load('Gauthier_26_04_PPG.mat')

load('Etienne_25_04_Timestamp.mat')
load('Etienne_25_04_PPG.mat')

Fs = 100.51; % sampling frequency
 
TimeBegin1 = 10*60*60+34*60+51; 
Timestamp1 = Gauthier_26_04_Timestamp;
Timestamp1 = (Timestamp1-Timestamp1(1))*10^(-3)+TimeBegin1;
PPG1 = Gauthier_26_04_PPG;
DPPG1 = abs(diff(diff(PPG1)));
THR_DPPG1 = DPPG1>500*mean(DPPG1);
% figure,
% findpeaks(DPPG1,'MinPeakHeight',200*mean(DPPG1))
TimeBegin3 = 15*60*60+24*60+14;
Timestamp3 = Etienne_25_04_Timestamp;
Timestamp3 = (Timestamp3-Timestamp3(1))*10^(-3)+TimeBegin3;
PPG3 = Etienne_25_04_PPG;
DPPG3 = abs(diff(diff(PPG3)));
THR_DPPG3 = DPPG3>500*mean(DPPG3);

figure, 
subplot(311)
plot(Timestamp1/60/60,PPG1)
grid on; axis('tight'),
title('PPG')
xlabel('time in Hour')
ylabel('Amplitude')
subplot(312)
plot(Timestamp1(1:end-2)/60/60,DPPG1)
grid on; axis('tight'),
title('D PPG')
xlabel('time in Hour')
ylabel('Amplitude')
subplot(313)
plot(Timestamp1(1:end-2)/60/60,THR_DPPG1)
grid on; axis('tight'),
ylim([-0.5, 1.5])
title('TH D PPG')
xlabel('time in Hour')
ylabel('Amplitude')

figure, 
subplot(311)
plot(Timestamp3/60/60,PPG3)
grid on; axis('tight'),
title('PPG')
xlabel('time in Hour')
ylabel('Amplitude')
subplot(312)
plot(Timestamp3(1:end-2)/60/60,DPPG3)
grid on; axis('tight'),
title('D PPG')
xlabel('time in Hour')
ylabel('Amplitude')
subplot(313)
plot(Timestamp3(1:end-2)/60/60,THR_DPPG3)
grid on; axis('tight'),
ylim([-0.5, 1.5])
title('TH D PPG')
xlabel('time in Hour')
ylabel('Amplitude')

index1 = find(THR_DPPG3>0);
index1(:,2) = floor(index1/Fs/60/60);
t = 1;
for k = 1:size(index1,1)
    if k == 1 || k == size(index1,1)
        index2(t,:)=index1(k,:);
        t = t+1;
    elseif k>1 && k<size(index1,1)
        if index1(k,2)~=index1(k-1,2)
            index2(t,:)=index1(k,:);
            t = t+1;
        end
        if index1(k,2)~=index1(k+1,2)
            if index2(t-1,1)~=index1(k,1)
                index2(t,:)=index1(k,:);
                t = t+1;
            end
        end              
    end
end

Dbuffer1 = diff(index2(:,1)/Fs/60);

for k = 1:length(Dbuffer1)
    if index2(k,2)+1 == index2(k+1,2)
        index2(k+1,:) = [0 0]; 
    end
end

index = index2(:,1); 
index(index==0) = [];

Dbuffer2 = diff(index/Fs/60);

for k = 1:length(Dbuffer2)
    if floor(index(k)/Fs/60/60)+1==floor(index(k+1)/Fs/60/60)
        if Dbuffer2(k)<1
            index(k) = 0;
        end
    end
end

index(index==0) = [];