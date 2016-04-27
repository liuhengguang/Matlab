function [ pulse, ind_R, R ] = detection_peack_min( signal, step )
% This function find the local maximum of a data by a step
% signal: data which is treated
% time: the step which the data is read
% pulse: number of maxima by step
% ind_R: indce of of local maxima
% R: value of local maxima

pulse = zeros(1,length(step)-1);
ind_R = [];
R = [];
for p = 1:length(step)-1
[R_inter ,ind_R_inter]= findpeaks(signal(step(p):step(p+1)));

ind_R_inter = ind_R_inter+step(p)-1;
ind_R = [ind_R ;ind_R_inter];
R = [R; R_inter];
end

for k = 2:length(R)
    if R(k)<R(k-1)
        if R(k)<mean(abs(diff(R)))
            R(k)=0;
            ind_R(k)=0;
        end
    end
end

if R(1)<R(2)
    if R(1)<mean(abs(diff(R)))
        R(1)=0;
        ind_R(1)=0;
    end
end
    
R = R(R~=0);
ind_R = ind_R(ind_R~=0);

for k = 1:length(step)-1
    for p = 1:length(ind_R)
        if ind_R(p)>step(k) && ind_R(p)<step(k+1)
            pulse(k) = pulse(k)+1;
        end
    end
end

end

