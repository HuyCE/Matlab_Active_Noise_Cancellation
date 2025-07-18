clc; clear all; close all;

%% - SET UP NOISE

% Sin noise

% Signal characteristics
sin_fs = 1000;             % Tần số lấy mẫu (Hz)
sin_T = 30;                 % Thời gian tín hiệu (giây)
sin_t = 0:1/sin_fs:sin_T-1/sin_fs;     % Vector thời gian
sin_N = sin_T * sin_fs;

% Frequencies element
f1 = 50;
f2 = 120;
f3 = 300;

% Amplitudes (tuỳ chọn)
A1 = 1;
A2 = 0.5;
A3 = 0.8;

% Tạo sóng sin đa tần số
noise_signal = A1*sin(2*pi*f1*sin_t) + A2*sin(2*pi*f2*sin_t) + A3*sin(2*pi*f3*sin_t);

% Recorded Noise
[y_noise, Fs_noise] = audioread("noise.wav");
y_renoise = y_noise(1:length(y_noise),1);

rec_Fs = Fs_noise;              % Sampling frequency (Hz)
duration = 5;           % Simulation duration (seconds)
N = length(y_renoise);      % Total number of samples
plot_numberOfSampler = linspace(0,length(y_renoise)/Fs_noise, length(y_renoise));


%% SETUP FILTER

% Adaptive filter setup
L_order = 1024; % filter order 
LMS_W = zeros(1,L_order); % Filter Coeficients
mu = 0.0003; %

% primary path model 
OL_order = 512;
of_low_pass = 6000; % 6kHz
of_high_pass = 20000; % 20kHz
of_sampling = 44100; % speaker sample rate
O_f = fir1(OL_order, [(of_low_pass/of_sampling/2) (of_high_pass/of_sampling/2)], 'bandpass'); % define filter model
O_f = O_f /norm(O_f);
of_delay = 5; %delay 5 sample
O_f = [zeros(1,of_delay), O_f];



% Original Secondary path model
SL_order = 256;
f_low_pass = 6000; % 6kHz
f_high_pass = 20000; % 20kHz
f_sampling = 44100; % speaker sample rate
S_f = fir1(SL_order, [(f_low_pass/f_sampling/2) (f_high_pass/f_sampling/2)], 'bandpass'); % define filter model
S_f = S_f /norm(S_f);
f_delay = 10; %delay 10 sample
S_f = [zeros(1,f_delay), S_f];

% Estiamte Secondary path model
S2_f = S_f + 0.1 * randn(size(S_f)) * max(abs(S_f)); % Add some noise to the true path
S2_f(S2_f < 0.01*max(abs(S2_f))) = 0; % Small values to zero for cleaner plot
S2_f = S2_f / norm(S2_f); % Normalize
if length(S2_f) < 60 % lenght of secondary path estimation filter S^z
    S2_f = [S2_f, zeros(1, 60 - length(S2_f))];
else
    S2_f = S2_f(1:60);
end
C = S2_f;


%% Experiments

% estimate filtered noise of primary path
d = filter(O_f, 1, noise_signal);


% system parameters
e = zeros(1, sin_N);
y = zeros(1, sin_N);


% buffer
xW_buffer = zeros(1,L_order);
X_buffer = zeros(1, 60);

X_estimated_2nd_path_buffer = zeros(1,60);
x_est_2nd_path = zeros(1,sin_N);

secondary_path_buffer = zeros(1,length(S_f));
y_after_secondary_path = zeros(1,sin_N);

% Looping
for n = 1:sin_N
    current_x = noise_signal(n);

    % update x buffer
    xW_buffer = [current_x, xW_buffer(1:L_order-1)];
    X_buffer = [current_x, X_buffer(1:60-1)];
    
    % calculate generated noise control signal y(n)
    y(n) = dot(LMS_W, xW_buffer);

    % passing control signal through secondary path S(n)
    secondary_path_buffer = [y(n), secondary_path_buffer(1:end-1)];
    y_after_secondary_path(n) = dot(S_f, secondary_path_buffer);
    
    % calculate error signal
    e(n) = d(n) - y_after_secondary_path(n);
        
    % passing reference noise signal to estimate sencondary path filter
    x_est_2nd_path(n) = dot(C,X_buffer);
    X_estimated_2nd_path_buffer = [x_est_2nd_path(n), X_estimated_2nd_path_buffer(1:end-1)];

    % LMS algo update W
    LMS_W = LMS_W + mu * x_est_2nd_path(n) * e(n);

    if any(isnan(LMS_W)) || any(isinf(LMS_W)) || isnan(e(n)) || isinf(e(n))
        fprintf('\n--- WARNING: Filter diverged at sample %d! ---\n', n);
        fprintf('This usually means the step size (mu_W) is too large.\n');
        fprintf('Try reducing mu_W (e.g., to 0.001, 0.0005, or smaller).\n');
        e(n:end) = NaN; % Mark remaining error samples as NaN
        break; % Exit the loop early
    end

    % Display progress
    if mod(n, sin_fs*0.5) == 0 % Every 0.5 seconds
        fprintf('Processing %d/%d samples (%.1f%%)\n', n, sin_N, (n/sin_N)*100);
    end
end

maximal_mu = 1 / (mean(x_est_2nd_path.*conj(x_est_2nd_path))*(L_order+f_delay))

%% Disp result
figure;

subplot(4,1,1)
plot(sin_t,noise_signal)
title('Generated Sin noise signal')
xlabel('Time')
ylabel('Amplitude')
grid on;
ylim([-2.5 2.5])

subplot(4,1,2)
plot(plot_numberOfSampler, y_renoise)
title('Recorded Noise signal')
ylabel('Amplitude')
xlabel('Time')
xlim([0 61])
grid on;

subplot(4,1,3)
plot(sin_t, e)
title('error estimated result')
xlabel('Time')
ylabel('Error amplitude')
