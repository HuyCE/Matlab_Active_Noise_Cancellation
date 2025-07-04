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

d =  filter(primary_path_response, 1, noise);
% x_quora = filter(est_2nd_path_response,1,noise);

% output
y = zeros(1,N);
e = zeros(1,N);

% buffer
x_buffer = d(1:L_order_FxLMS);
y_buffer = zeros(1, sencondary_path_order);
x_2nd_buffer = zeros(1, est_2nd_path_order);
debug_norm_W = zeros(1, N);
y_filtered_buffer = zeros(1,N);
true_e = zeros(1,N);

% figure
plot_res_fig = figure;
% loop
for n=L_order_FxLMS:N-L_order_FxLMS;
    % Update x buffer 
    x_buffer = [noise(n) x_buffer(1:end-1)];
    x_2nd_buffer = [noise(n) x_2nd_buffer(1:end-1)];

    
    % Estimate output control signal
    y(n) = dot(W_FxLMS, x_buffer);

    % Passing control signal throw 2nd path
    y_buffer = [y(n) y_buffer(1:end-1)];
    res = conv(secondary_path_response, y_buffer);
    y_filtered(n) = res(30);

    % Estimate residual error 
    e(n) = d(n) - y_filtered(n);    
    true_e(n) = d(n-20) + y_filtered(n);

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

    subplot(5,2,[1 2]);
    stem(x_buffer);
    ylim([-5 5]);
    title("X buffer");

    subplot(5,2,[3 4]);
    stem(res(10:50));
    ylim([-5 5]);
    title("y output");

    subplot(5,2,5);
    plot(t, e);
    title("residual error");

    subplot(5,2,6);
    plot(t,y);
    title("y after 2nd path");

    subplot(5,2,[7 8]);
    plot(t,true_e);
    title("true e signal");

    subplot(5,2,[9 10]);
    plot(t,debug_norm_W);
    title('debug norm');
    pause(0.005)
end

close(plot_res_fig);

%% Plot data
% figure;
% subplot(5,1,1);
% plot(t,d);
% title("Primary noise");
% 
% subplot(5,1,2);
% plot(t, e);
% title("residual error");
% 
% subplot(5,1,3);
% plot(t,y);
% title("y after 2nd path");
% 
% subplot(5,1,4);
% plot(t,true_e);
% title("true e signal");
% 
% subplot(5,1,5);
% plot(t,debug_norm_W);
% title('debug norm');

