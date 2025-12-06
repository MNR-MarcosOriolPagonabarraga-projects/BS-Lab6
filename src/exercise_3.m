%% ===============================================================
%  EXERCISE 3 — ERP Features vs Number of Trials
%  P3 (stimulus-locked) and ERN (response-locked)
%  Channels: Fz (5), Cz (14), Pz (23)
% ===============================================================

clear; clc; close all;

name = 'V13PLA.CNT';

channels = [5, 14, 23];              % Fz, Cz, Pz
chan_names = {'Fz','Cz','Pz'};

pair_incong = [2 1; 4 8];            % P3 → only incongruent
triplet_all = [1 8 1;2 8 1;3 1 8;4 1 8];  % ERN → all corrections

sample_rate = 250; % Hz

%% ===============================================================
%  DEFINE CORRECT TIME WINDOWS (IN SAMPLES)
% ===============================================================

% Epochs are 1400 ms long → 400 ms BEFORE response → 1000 after
% 0 ms = sample 101
zero_index = round(0.400 * sample_rate) + 1;  % = 100 + 1 = 101

% P3 window → 250–600 ms after stimulus onset
P3_window = zero_index + round([0.250 0.600] * sample_rate);

% ERN window → 0–100 ms after error response
ERN_window = zero_index + round([0 0.100] * sample_rate);

%% ===============================================================
%  PREALLOCATE RESULTS
% ===============================================================

maxN = 200; % maximum number of trials to test
step = 5;

num_steps = floor(maxN/step);

P3_amp = zeros(3, num_steps);
P3_lat = zeros(3, num_steps);

ERN_amp = zeros(3, num_steps);
ERN_lat = zeros(3, num_steps);

%% ===============================================================
%  MAIN LOOP OVER CHANNELS
% ===============================================================

for c = 1:3

    %% ===== Load Stimulus-locked epochs (incongruent only) =====
    stim_data = promedioStimulusLocked(name, pair_incong, channels(c));
    total_epochs_stim = size(stim_data,1);

    %% ===== Load Response-locked epochs (all corrections) =====
    resp_data = promedioResponseLocked(name, triplet_all, channels(c));
    total_epochs_resp = size(resp_data,1);

    %% ===== Loop over N = 5,10,15,... =====
    idx = 1;

    for N = step:step:maxN

        %% ---------------- P3 ANALYSIS ----------------
        if N <= total_epochs_stim
            avg_stim = mean(stim_data(1:N, :), 1);

            % Amplitude (max) and latency (ms)
            [ampP3, posP3] = max(avg_stim(P3_window(1):P3_window(2)));
            P3_amp(c, idx) = ampP3;

            % Convert position to real latency in ms
            P3_lat(c, idx) = (posP3 + P3_window(1) - zero_index) / sample_rate * 1000;
        end

        %% ---------------- ERN ANALYSIS ----------------
        if N <= total_epochs_resp
            avg_resp = mean(resp_data(1:N, :), 1);

            % Amplitude (min) and latency (ms)
            [ampERN, posERN] = min(avg_resp(ERN_window(1):ERN_window(2)));
            ERN_amp(c, idx) = ampERN;

            % Convert position to latency in ms
            ERN_lat(c, idx) = (posERN + ERN_window(1) - zero_index) / sample_rate * 1000;
        end

        idx = idx + 1;
    end
end

%% ===============================================================
%  PLOTTING THE RESULTS
% ===============================================================

N_values = step:step:maxN;

figure;

% ---------- 1. P3 amplitude ----------
subplot(2,2,1); hold on;
plot(N_values, P3_amp(1,:), 'LineWidth', 1.4)
plot(N_values, P3_amp(2,:), 'LineWidth', 1.4)
plot(N_values, P3_amp(3,:), 'LineWidth', 1.4)
title('P3 Amplitude vs Number of Trials')
xlabel('Number of Averaged Trials'); ylabel('Amplitude [\muV]');
legend('Fz','Cz','Pz'); grid on;

% ---------- 2. ERN amplitude ----------
subplot(2,2,2); hold on;
plot(N_values, ERN_amp(1,:), 'LineWidth', 1.4)
plot(N_values, ERN_amp(2,:), 'LineWidth', 1.4)
plot(N_values, ERN_amp(3,:), 'LineWidth', 1.4)
title('ERN Amplitude vs Number of Trials')
xlabel('Number of Averaged Trials'); ylabel('Amplitude [\muV]');
legend('Fz','Cz','Pz'); grid on;

% ---------- 3. P3 latency ----------
subplot(2,2,3); hold on;
plot(N_values, P3_lat(1,:), 'LineWidth', 1.4)
plot(N_values, P3_lat(2,:), 'LineWidth', 1.4)
plot(N_values, P3_lat(3,:), 'LineWidth', 1.4)
title('P3 Latency vs Number of Trials')
xlabel('Number of Averaged Trials'); ylabel('Latency [ms]');
legend('Fz','Cz','Pz'); grid on;

% ---------- 4. ERN latency ----------
subplot(2,2,4); hold on;
plot(N_values, ERN_lat(1,:), 'LineWidth', 1.4)
plot(N_values, ERN_lat(2,:), 'LineWidth', 1.4)
plot(N_values, ERN_lat(3,:), 'LineWidth', 1.4)
title('ERN Latency vs Number of Trials')
xlabel('Number of Averaged Trials'); ylabel('Latency [ms]');
legend('Fz','Cz','Pz'); grid on;

