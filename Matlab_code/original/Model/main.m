clear all; clc;close all;

% Noise generate 
[noise, N, t] = Noise_generator();

% Init Paths model
[primary_path_response, primary_path_order] = Primary_path_model();

[secondary_path_response, sencondary_path_order] = Second_path_model();

[est_2nd_path_response, est_2nd_path_order] = Estimate_2nd_path(secondary_path_response);

[ref_mic_response, ref_mic_order] = ref_mic_filter();

% Setup
[W_FxLMS, L_order_FxLMS, mu_FxLMS] = Adaptive_filter();

%% Experiment

d = filter(primary_path_response,1 , noise); % Pre-run primary path filter

% Define buffers
x_buffer = zeros(1,L_order_FxLMS);
y_buffer = zeros(1, sencondary_path_order);
e_buffer = zeros(1,L_order_FxLMS);
% Setup output storages
y = zeros(1,N);
y_filtered = zeros(1,N);
e = zeros(1,N);
debug_norm_W = zeros(1,N);
ref_signal_with_feedback = noise;
MSE_intimeEstimate = zeros(1,N);
Noise_cancellingRate = zeros(1,N);
coverageRate = zeros(1,N);

% what if I combine output with the ref input 

for n = 1:N
    % Update x_buffers
    x_buffer = [noise(n) x_buffer(1:end-1)];
    
    % update noise buffer for adaptive filter generate y(n)
    y(n) = dot(W_FxLMS, x_buffer);
    
    % update the y buffer for 2nd path filter
    y_buffer = [y(n) y_buffer(1:end-1)];

    % Passing control signal y(n) through 2nd path
    y_filtered(n) = dot(secondary_path_response, y_buffer);
    % Estimate error 
    e(n) = d(n) - y_filtered(n);
    % Update e_buffer
    e_buffer = [e(n) e_buffer(1:end-1)];

    MSE_intimeEstimate(n) = mean(e(1:n).^2);
    Noise_cancellingRate(n) = 10*log10( (mean(x_buffer.^2)/mean(e_buffer.^2) ));
    coverageRate(n) = 10*log10(mean(e(1:n).^2));

    % Update the LMS weight
    W_FxLMS = W_FxLMS + mu_FxLMS * e(n) * x_buffer;
    debug_norm_W(n) = vecnorm(W_FxLMS,2,2);

end



%% Plot data
close all;
% figure;
% 
% subplot(6,1,1);
% plot(t,noise);
% title("Source Noise");
% hold on;
% xlabel('Time');
% ylabel('Altidute');
% 
% subplot(6,1,2);
% plot(t,y_filtered);
% title("Control signal");
% hold on;
% xlabel('Time');
% ylabel('Altidute');
% 
% subplot(6,1,3)
% plot(t,e);
% title("error messured");
% hold on;
% xlabel('Time');
% ylabel('Altidute');
% 
% subplot(6,1,4);
% plot(t,debug_norm_W);
% hold on;
% title('Adaptive Filter Vector Norm ')
% xlabel('Time');
% ylabel('Vector Norm');
% 
% subplot(6,1,5);
% iteration = linspace(1,N,N);
% plot(iteration, MSE_intimeEstimate);
% hold on;
% title('MSE');
% xlabel('Iteration');
% ylabel('Error Power(db)');
% 
% subplot(6,1,6)
% plot(t,Noise_cancellingRate);
% hold on;
% title("Noise Cancelling Rate");
% xlabel("Time")
% ylabel("dB")

de_noise_fig = figure;
plot(t,noise);
hold on;
title("Recorded Noise signal");
xlabel('Time');
ylabel('Amplitude');

signal_fig = figure;
subplot(3,1,1);
plot(t,noise);
hold on;
title("Recorded Noise signal");
xlabel('Time');
ylabel('Amplitude');

subplot(3,1,2); 
plot(t,y_filtered);
hold on;
title('Generated Control Signal');
xlabel('Time');
ylabel('Amplitude');

subplot(3,1,3);
plot(t,e);
hold on;
title('Error Estimated');
xlabel('Time');
ylabel('amplitude');

VecNorm_fig = figure;
plot(t, debug_norm_W);
hold on;
title('Adaptive Filter Vector Norm');
xlabel('Time');
ylabel('Vector Norm');


MSE_fig = figure;
iteration = linspace(1,N,N);
plot(iteration, MSE_intimeEstimate);
hold on;
title('MSE');
xlabel('Iteration');
ylabel('Error Power(db)');

NSR_fig = figure;
plot(t,Noise_cancellingRate);
hold on;
title("Noise Cancelling Rate");
xlabel("Time")
ylabel("dB")

%%

