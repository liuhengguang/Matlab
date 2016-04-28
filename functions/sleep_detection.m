function [ sleep, rest ] = sleep_detection( ACCEL, Fs )
% This function detects a sleep activity by stuying the accelerometer
% ACCEL: Accelerometer matix containing X, Y and Z axes value
% Fs: sampling frequency 
% sleep: sleep vector detection sampling at 2 minutes, if 0 awake, if 1
% sleeping
% rest: vector detecting a movement sampling at 2 minutes, if 0 moving,
% if 1 resting


T =30;
timeTsec = 1:floor(Fs*T):size(ACCEL,1);
timeTsec(end+1) = size(ACCEL,1)-1;
diff_ACCEL = abs(diff(ACCEL));

mean_ACCEL = zeros(length(timeTsec)-1,3);

for k =1:length(timeTsec)-1
    mean_ACCEL(k,:) = mean(diff_ACCEL(timeTsec(k):timeTsec(k+1),:));
end

log_mean_ACCEL = abs(diff(10*log(mean_ACCEL)));
time2min = 1:floor(Fs*60*2):size(ACCEL,1);
time2min(end+1) = size(ACCEL,1);
rest = zeros(1,length(time2min)-1);

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
            rest(k)=1;
        end
    end
end

count0 = 0;
count1 = 0;
Nb_cut = 4;
sleep = zeros(1,length(rest));

for k = 2:length(rest)
    
    if rest(k) == 1 
        count0 = count0+1;
        count1 = 0;
    end
    
    if rest(k)==0
        count1 = count1 +1;
        if count0 ~= 0
            count0 = count0+1;
        end
    end
        
    if count0 ~= 0 && count1 > Nb_cut
        if count0>3+Nb_cut
           sleep(k+1-count0+Nb_cut:k)=ones(1,count0-Nb_cut);
        end
        count0 = 0;
    end
end

end

