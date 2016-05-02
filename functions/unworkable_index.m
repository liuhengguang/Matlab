function [ index ] = unworkable_index( Fs, PPG  )
% This function gives the index of the PPG signal when the bracelet has not
% capted any signal
% Fs: sampling frequency
% PPG: PPG signals vector
% index: vector of the index xhere the bracelet did not save any signals

%% Signal and Data definitions

DPPG = abs(diff(diff(PPG)));
THR_DPPG = DPPG>500*mean(DPPG);

index1 = find(THR_DPPG>0);
index1(:,2) = floor(index1/Fs/60/60);
index2 = [];
%% Detection
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

if size(index2,1) ~= 0
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
else
    index(1)=1;
    index(2)=length(PPG);
end
end

