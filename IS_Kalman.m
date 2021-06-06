function [Xhat, Est_Err, Z, X] = IS_Kalman(wifiresult,cellresult,original_loc,velocity,accl,time,cellular_error,wifi_error)

% Sensor Fusion using Kalman filter
% Fusing two position measurement and velocity measurement to get position

%% Initialise matrix 

% Process Noise matrix (Q)
% This model includes process Noise,
Proccess_Noise=[1 0 0 0; % previously 1.6
        0 1 0 0;
        0 0 0.02 0;
        0 0 0 0.02]; 
        
% Time interval
dt= time; % Previous 0.4
                  
% Observation_matrix (m x n) m = number of measurements 
observation = diag(ones(1,4));
observation_matrix = [observation;observation(1:2,:)];

%% Load data

% Actual/esxpected location measurement
% [x,y]
for i = 1:length(original_loc)
    X(:,i) = [original_loc(i,1);original_loc(i,2)];
end

% [x,y;vx,vy]
% Observation Measurement 
for i = 1:length(wifiresult)
    Z(:,i) = [wifiresult(i,1);wifiresult(i,2);velocity(:,i);0;cellresult(i,1);cellresult(i,2)];
end  

% Control input
% for i = 1:length(accl)
%     U(:,i) = [accl(:,i);0;0];
% end 

% Initial condition as per assumption for state matrix
% [x,y,vx,vy]
Xhat(:,1)=[cellresult(1,1);cellresult(1,2);velocity(:,1);velocity(:,1)];

% inital value of co-variance of estimation error (P) (standard deviation
% error) (n x n)
Est_Err(:,:,1)=[0.015 0 0 0;
              0 0.005 0 0;
              0 0 0.1 0;
              0 0 0 0.1];   

% indicator function. Used for unwrapping of tan
%ind=0;
%% Kalman Filter

for n = 1:length(wifiresult)-1
    
% R matrix (Initialise measurement error matrix)
Measure = [wifi_error(n+1) wifi_error(n+1) 0.001 0.001 cellular_error(n+1) cellular_error(n+1)];
Mes_Noise = diag(Measure);
   
% System Dynamics (n x n)
system_dynamic=[1 0 dt(n+1) 0;
                0 1 0 dt(n+1);
                0 0 1 0;
                0 0 0 1;];
 % control matrix (B)           
%  control_matrix = [(1/2*dt(n+1)^2) 0;
%                    0 (1/2*dt(n+1)^2);
%                    dt(n+1) 0;
%                    0 dt(n+1);];
    
    % Calculate the state estimate
        [Xhat(:,n+1)]=stateEstimate(system_dynamic,Xhat(:,n)); % ,control_matrix,U(:,n)
    
    % Prediction estimate and Error Covariance (P)
        [Est_Err(:,:,n+1)]= predictionEstimate_ErrorCovariance(system_dynamic,Est_Err(:,:,n),Proccess_Noise);
    
    % Correction Equations
          
        % Computation of Jacobian Matrix, for transformation
%         H(:,:,n+1)=JacobianMatrixCalc(Xhat(1,n+1),Xhat(2,n+1),Xhat(3,n+1));
        
    % Kalman Gain Computation
        K(:,:,n+1)=KalmanGainCalc(observation_matrix,Est_Err(:,:,n+1),Mes_Noise);
        
    % Innovation Computation
    % Non-linear Mapping
        Inov= estimation_calc(Z(:,n+1),Xhat(:,n+1),observation_matrix);
        
    % Final estimation Computation
        Xhat(:,n+1)=Xhat(:,n+1)+ K(:,:,n+1)*Inov; 
    % Covarience of estimation error
        Est_Err(:,:,n+1)=(eye(4)-K(:,:,n+1)*observation_matrix)*Est_Err(:,:,n+1);
        
%      % Unwrapping of tan
%         theta1=AngleUnwrap(Xh(1,n+1),Xh(2,n+1),0); 
%         theta=AngleUnwrap(Xh(1,n),Xh(2,n),0);
        
%         if abs(theta1-theta)>=pi
%             if ind==1
%                 ind=0;    
%         else
%             ind=1;
%             end
%         end
end
end