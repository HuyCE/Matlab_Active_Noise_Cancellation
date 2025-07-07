clear; clc;

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

% Setup output storages
y = zeros(1,N);
y_filtered = zeros(1,N);
e = zeros(1,N);
debug_norm_W = zeros(1,N);


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

    % Update the LMS weight
    W_FxLMS = W_FxLMS + mu_FxLMS * e(n) * x_buffer;
    debug_norm_W(n) = norm(W_FxLMS);

end



%% Plot data
figure;

subplot(5,1,1);
plot(t,noise);
title("Noise");

subplot(5,1,2);
plot(t, d);
title("Primary noise");

subplot(5,1,3);
plot(t,y);
title("Control signal");

subplot(5,1,4)
plot(t,e);
title("error messured");

subplot(5,1,5);
plot(t,debug_norm_W);
title('debug norm');
