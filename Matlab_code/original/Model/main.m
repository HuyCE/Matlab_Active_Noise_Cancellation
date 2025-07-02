clear; close; clc;

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

d = filter(primary_path_response, 1, noise);
% x_quora = filter(est_2nd_path_response,1,noise);

% output
y = zeros(1,N);
e = zeros(1,N);

% buffer
x_buffer = zeros(1, L_order_FxLMS);
y_buffer = zeros(1, sencondary_path_order);
x_2nd_buffer = zeros(1, est_2nd_path_order);
debug_norm_W = zeros(1, N);

% loop
for n=1:N
    % Update x buffer 
    x_buffer = [noise(n) x_buffer(1:end-1)];
    x_2nd_buffer = [noise(n) x_2nd_buffer(1:end-1)];

    
    % Estimate output control signal
    y(n) = dot(W_FxLMS, x_buffer);

    % Passing control signal throw 2nd path
    y_buffer = [y(n) y_buffer(1:end-1)];
    y_filtered = dot(secondary_path_response, y_buffer);
    

    % Estimate residual error 
    e(n) = d(n) + y_filtered;

    % Estimate filtered ref signal
    x_filtered = dot(est_2nd_path_response, x_2nd_buffer);

    % Update W filter 
    debug_norm_W(n) = norm(W_FxLMS);
    W_FxLMS = W_FxLMS + mu_FxLMS * e(n) * x_filtered;
    

    if any(isnan(W_FxLMS)) || any(isinf(W_FxLMS)) || isnan(e(n)) || isinf(e(n))
        fprintf('\n--- WARNING: Filter diverged at sample %d! ---\n', n);
        fprintf('This usually means the step size (mu_W) is too large.\n');
        fprintf('Try reducing mu_W (e.g., to 0.001, 0.0005, or smaller).\n');
        e(n:end) = NaN; % Mark remaining error samples as NaN
        break; % Exit the loop early
    end
end

%% Plot data

figure;
subplot(5,1,1)
plot(t, noise);

subplot(5,1,2)
plot(t, e);
title("residual error")

subplot(5,1,3)
plot(t,y)

subplot(5,1,4)
plot(t,debug_norm_W);