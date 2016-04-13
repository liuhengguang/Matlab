function [ X_k_k , M ] = kalman( Phi_k, R, X ,Order, X_0_0, P_0_0)
% Kalman algorithm

%  Phi_k: is the state transition model which is applied to the previous
%  state x(k?1)
%  R: variance of the noise 
%  X: signal which is studied
%  Order: Order of the AR processus
%  X_0_0: initialization of 
%  P_0_0: initialization of 
if size(X,1)==1
    X = transpose(X);
end

 % Initialization
 X_kmoins1_kmoins1 = transpose(X_0_0);
 P_kmoins1_kmoins1 = P_0_0;

 n = length(X);

for i = 1:n - Order
    
    % Observation at time k
    y_k = X(Order + i);
    % Observation matrix
    H_k = X(1 + (i-1) : (i-1) + Order);
    
    %-------PREDICTION-----------------------------------------------------
    X_k_kmoins1 = Phi_k*X_kmoins1_kmoins1;
  
    P_k_kmoins1 = Phi_k*P_kmoins1_kmoins1*transpose(Phi_k);
    
    %-------UPDATE = CORRECTION---------------------------------------
    % Gain of Kalman
    K_k = P_k_kmoins1*H_k*(transpose(H_k)*P_k_kmoins1*H_k+R)^(-1); 
    
    % Innovation
    I = y_k - transpose(H_k)*X_k_kmoins1;
    
    X_k_k = X_k_kmoins1 + K_k*I;
    
    P_k_k = (eye(Order) - K_k*transpose(H_k))*P_k_kmoins1*transpose(eye(Order) - K_k*transpose(H_k)) + K_k*R*transpose(K_k);
    
    
    
    %-------PREVIOUS ESTIMATION----------------------------------------
    X_kmoins1_kmoins1 = X_k_k;
    
    P_kmoins1_kmoins1 = P_k_k;
    
    M(i,:) = X_kmoins1_kmoins1';

end

end

