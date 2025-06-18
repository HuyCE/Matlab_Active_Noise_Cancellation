% Example of S(z) (Actual Secondary Path) and S_hat(z) (Estimated Secondary Path)
% in MATLAB for ANC FXLMS context.

clear;
clc;
close all;

%% 1. Define the "True" Secondary Path S(z)
% This represents the actual physical acoustic path from the anti-noise
% loudspeaker to the error microphone.
% We'll model it as an FIR filter with a certain impulse response.

Fs = 8000; % Sampling frequency
delay_samples = 10; % Acoustic delay in samples
filter_order = 50;  % Length of the FIR filter (number of taps - 1)

% Design a base FIR filter (e.g., a bandpass filter to simulate room acoustics)
% fir1(order, Wn, 'ftype') creates an FIR filter.
% Wn = [lower_normalized_freq, upper_normalized_freq]
% Normalized frequency is from 0 to 1, where 1 corresponds to Nyquist (Fs/2).
h_S_true_base = fir1(filter_order, [200/(Fs/2), 1000/(Fs/2)], 'bandpass');

% Add a realistic delay to the true secondary path
h_S_true = [zeros(1, delay_samples), h_S_true_base];

% Normalize the impulse response for consistent amplitude (optional but good practice)
h_S_true = h_S_true / norm(h_S_true);

fprintf('Length of True Secondary Path S(z) (h_S_true): %d taps\n', length(h_S_true));

%% 2. Define the "Estimated" Secondary Path S_hat(z)
% This represents the model of S(z) that the ANC system uses.
% In a real system, this would be identified (e.g., using LMS/NLMS).
% Here, we'll create it with some intentional error/mismatch compared to h_S_true.

% S_hat will typically have a similar length to S, or be slightly shorter/longer.
filter_order_est = 60; % Can be different from true path length for estimation.

% Start with a version that's close to the true path
h_S_est_base = fir1(filter_order_est, [220/(Fs/2), 1100/(Fs/2)], 'bandpass'); % Slightly different freq response

% Add a slightly different delay to simulate estimation error
delay_samples_est = 8;
h_S_est = [zeros(1, delay_samples_est), h_S_est_base];

% Trim or pad h_S_est to a consistent length (e.g., Lc in your FXLMS code)
Lc_for_estimation = 80; % The fixed length of the filter used for estimation
if length(h_S_est) < Lc_for_estimation
    h_S_est = [h_S_est, zeros(1, Lc_for_estimation - length(h_S_est))];
else
    h_S_est = h_S_est(1:Lc_for_estimation);
end

% Add some random noise to coefficients to simulate identification error
noise_level = 0.05 * max(abs(h_S_est)); % 5% of max amplitude
h_S_est = h_S_est + noise_level * (2*rand(size(h_S_est)) - 1); % Uniform random noise

% Normalize the estimated impulse response
h_S_est = h_S_est / norm(h_S_est);

fprintf('Length of Estimated Secondary Path S_hat(z) (h_S_est): %d taps\n', length(h_S_est));

%% 3. Visualize the Impulse Responses

figure;
subplot(2,1,1);
stem(0:length(h_S_true)-1, h_S_true);
title('True Secondary Path Impulse Response, S(z)');
xlabel('Samples');
ylabel('Amplitude');
grid on;
legend('S(z)');

subplot(2,1,2);
stem(0:length(h_S_est)-1, h_S_est, 'r');
title('Estimated Secondary Path Impulse Response, S\_hat(z)');
xlabel('Samples');
ylabel('Amplitude');
grid on;
legend('S\_hat(z)');

% Overlay to see the mismatch
% figure;
% plot(0:length(h_S_true)-1, h_S_true, 'b', 'DisplayName', 'S(z) - True');
% hold on;
% % Pad h_S_est if it's shorter than h_S_true for plotting
% plot_h_S_est = h_S_est;
% if length(plot_h_S_est) < length(h_S_true)
%     plot_h_S_est = [plot_h_S_est, zeros(1, length(h_S_true) - length(plot_h_S_est))];
% end
% plot(0:length(h_S_true)-1, plot_h_S_est, 'r--', 'DisplayName', 'S\_hat(z) - Estimated');
% title('Comparison of S(z) and S\_hat(z) Impulse Responses');
% xlabel('Samples');
% ylabel('Amplitude');
% legend('show');
% grid on;

figure;
subplot(2,1,1)
stem(h_S_true_base)
title("H S true base")

subplot(2,1,2)
stem(h_S_true)
title("H S true")
%% 4. Compare Frequency Responses
% Use freqz to get the frequency response of both filters

NFFT = 1024; % Number of FFT points for frequency response
[H_S_true, f_true] = freqz(h_S_true, 1, NFFT, Fs);
[H_S_est, f_est] = freqz(h_S_est, 1, NFFT, Fs);

figure;
subplot(2,1,1);
plot(f_true, 20*log10(abs(H_S_true)));
hold on;
plot(f_est, 20*log10(abs(H_S_est)), 'r--');
title('Magnitude Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
legend('S(z) - True', 'S\_hat(z) - Estimated');
grid on;
xlim([0 Fs/2]);

subplot(2,1,2);
plot(f_true, unwrap(angle(H_S_true))*180/pi); % unwrap for continuous phase
hold on;
plot(f_est, unwrap(angle(H_S_est))*180/pi, 'r--');
title('Phase Response');
xlabel('Frequency (Hz)');
ylabel('Phase (Degrees)');
legend('S(z) - True', 'S\_hat(z) - Estimated');
grid on;
xlim([0 Fs/2]);

% Calculate Phase Mismatch (important for stability)
phase_mismatch = unwrap(angle(H_S_true)) - unwrap(angle(H_S_est));
figure;
plot(f_true, abs(phase_mismatch)*180/pi); % Absolute phase difference
title('Absolute Phase Mismatch Between S(z) and S\_hat(z)');
xlabel('Frequency (Hz)');
ylabel('Absolute Phase Difference (Degrees)');
grid on;
xlim([0 Fs/2]);
