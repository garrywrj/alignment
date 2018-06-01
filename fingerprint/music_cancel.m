
clear
clear_hashtable
load('Z:\fingerprint\4.5录音\library_hashtable.mat');
%load('Z:\fingerprint\4.5录音\t1.mat');
[dt,srt] = mp3read('Z:\fingerprint\4.5录音\录音\ref_query_1_R.mp3');

% Run the query
R = match_query(dt,srt);
% R returns all the matches, sorted by match quality.  Each row
% describes a match with three numbers: the index of the item in
% the database that matches, the number of matching hash landmarks,
% and the time offset (in 32ms steps) between the beggining of the
% reference track and the beggining of the query audio.
R(1,:)
% 5 18 1 18 means tks{5} was matched with 18 matching landmarks, at a
% time skew of 1 frame (query starts ~ 0.032s after beginning of
% reference track), and a total of 18 hashes matched that track at 
% any time skew (meaning that in this case all the matching hashes 
% had the same time skew of 1).
%
% Plot the matches
[DM,SRO,TK,T,name] = illustrate_match(dt,srt,tks);
time = T * 0.032;
colormap(1-gray)
ref_music = audioread([dirname '\' name '.mp3']);

time_start = time * SRO;
time_end = time_start + length(dt)/16*44.1;

ref_music = ref_music(time_start:time_end,1);
ref = resample(ref_music,16000,44100);
ref = ref(1:length(dt),1);



input = importdata('sample_data.mat');
fs = input.fs;
primary = dt';
reference = ref';
primary_size = size(primary,2);
Epsilon = 0.0001;
AllData = zeros(1,3);
 

for order = 30
    W_1 = zeros(order,1);  
    W_2 = zeros(order,1);
    
    performance_curve1 = zeros(46500,1);    
    performance_curve2 = zeros(18461,1);
    primary_wrt_filter = primary(1 , order:end);  %truncate primary
    reference_wrt_filter = zeros((primary_size - order),order);
    for update = (order) : primary_size                     %make reference_wrt_filter according to filter
        for update1=1:order
         reference_wrt_filter((update-order+1),update1) =  reference(update-update1+1);
        end  
    end
    
    disp(size(reference_wrt_filter,1));
    
%    for Nu = 0.001:(2 * 0.01):1
    for Nu = 0.05
%        for iterateReference = 1: size(reference_wrt_filter,1)
         for iterateReference = 1: size(reference_wrt_filter,1)
            MSE =0;
            Error = primary_wrt_filter(1, iterateReference) - (reference_wrt_filter(iterateReference,:) * W_2(:,1));
            X = reference_wrt_filter(iterateReference,:);
            Nu_by_Epsilon = Nu / (Epsilon + (X * X'));
            if iterateReference < 46501
                Error = primary_wrt_filter(1, iterateReference) - (reference_wrt_filter(iterateReference,:) * W_1(:,1));
                W_1 = W_1 + (Nu_by_Epsilon * (Error * X)');
                
                errorSquare = (primary_wrt_filter(1, 1:iterateReference)' - (reference_wrt_filter(1:iterateReference, :) * W_1(:,1))).^2;

                MSE = sum(errorSquare)/(iterateReference);
                performance_curve1(iterateReference,1) = MSE; 
                
            end  
            W_2 = W_2 + (Nu_by_Epsilon * (Error * X)');
            
            if iterateReference >= 46501
                errorSquare1 = (primary_wrt_filter(1, 46501:iterateReference)' - (reference_wrt_filter(46501:iterateReference, :) * W_2(:,1))).^2;

                MSE = sum(errorSquare1)/(iterateReference-46500);
                performance_curve2(iterateReference-46500,1) = MSE;
            end
                    
         end
%         MSE = sum(primary_wrt_filter - (reference_wrt_filter * W_1)')^2;
%         AllData(size(AllData,1)+1,1) = order;        
%         AllData(size(AllData,1),2) = Nu;
%         AllData(size(AllData,1),3) = MSE;
    end
    
Out = (primary_wrt_filter(1, 1:46500) - (reference_wrt_filter(1:46500,:) * W_1)');
Out1 = (primary_wrt_filter(1, 46501:end) - (reference_wrt_filter(46501:end,:) * W_2)');
Out3 = vertcat(Out', Out1');

SNR_parameter = mean(primary_wrt_filter.^2)/mean(Out3.^2);
SNR_After = 10 * log10(SNR_parameter);
figure;
plot(performance_curve1);
title('Learning Curve For Filter Order = 50 and Iteration < 46.5K');
xlabel('Iteration -->');
ylabel('MSE -->');
legend('Nu = 0.05');

figure;
plot(performance_curve2);
title('Learning Curve For Filter Order = 50 and Iteration > 46.5K');
xlabel('Iteration -->');
ylabel('MSE -->');
legend('Nu = 0.05');
% 
figure;
plot(Out3);
title('Error Signal After Applying NLMS For Filter Order = 50');
xlabel('Iteration -->');
ylabel('Error (Desired Output Signal) -->');
legend('Nu = 0.05');
%soundsc(Out3,fs);
end
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lms = dsp.LMSFilter('Length',2048, ...
%    'Method','Normalized LMS',...
%    'AdaptInputPort',true, ...
%    'StepSizeSource','Input port', ...
%    'WeightsOutputPort',false);
% 
% 
% a = 1; % adaptation control
% mu = 0.05; % step size
% [y, err] = lms(ref,dt,mu,a);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure(1);
% subplot(211);plot(dt);title('未归一化');
% subplot(212);plot(ref);
% 
% alpha = 0.5;
% mu = 0.0005;
% M = 3500;
% 
% 
% dt = dt - mean(dt);dt = dt/max(abs(dt));
% ref = ref - mean(ref);ref = ref/max(abs(ref)); %去直流，归一
% 
% figure(2);
% subplot(211);plot(dt);title('归一化后');
% subplot(212);plot(ref);
% 
% [e,y] = NLMS(dt,ref,mu,M,alpha);
% 
% figure(3);
% subplot(211);plot(dt);title('滤波输出');
% subplot(212);plot(e);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [e,y] = NLMS(d, u, m, M, a)
% 
% % Initialization
% 
%  Ns = length(d);
% if (Ns ~= length(u))  
%     return; 
% end
% 
% u = [zeros(M-1, 1); u];
% w = zeros(M,1);
% y = zeros(Ns,1);
% e = zeros(Ns,1);
% 
%    for n = 1:Ns
%        uu = u(n+M-1:-1:n);
%        k=(uu*m)/(a+norm(uu));
%        y(n) = w'*uu;
%        e(n) = d(n) - y(n);
%        w = w + e(n)*k;
%     end
%   
% 
% 
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%