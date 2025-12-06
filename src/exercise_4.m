%% ===============================================================
%  EXERCISE 4 — VSTM TASK (Student 2)
%  P300 Analysis & Behavioral Metrics
% ===============================================================
clear; clc; close all;

% Load Student 2 data
load('student2.mat'); % Ensure this file is in your folder
fs = 250;
num_channels = 14; 

% Event codes: 4 (Congruent), 5 (Incongruent), 1 (Correct), 0 (Incorrect)
% Epoch: -100ms to 1000ms. 
% Baseline: -100ms to 0ms.
epoch_sec = [-0.1 1.0];
epoch_samps = round(epoch_sec * fs); 
t_axis = linspace(epoch_sec(1), epoch_sec(2), diff(epoch_samps)+1);
base_samps = round(0.1 * fs); % 100ms baseline

% Filter setup: 7Hz Low Pass
[b, a] = butter(2, 7/(fs/2), 'low');

% Preallocate storage for averages (Channel x Time)
sum_cong = 0; n_cong = 0;
sum_incong = 0; n_incong = 0;

% Find Trigger Indices
trigs = marks;
times = marksamples;

RT_cong = [];
RT_incong = [];

for i = 1:length(trigs)-1
    code = trigs(i);
    next_code = trigs(i+1);
    
    % Check if it is a 2nd Image Stimulus (4 or 5) followed by Correct (1)
    if (code == 4 || code == 5) && next_code == 1
        
        % Calculate Response Time (Sample diff / fs)
        rt = (times(i+1) - times(i)) / fs;
        
        % Extract Epoch
        idx_start = times(i) + epoch_samps(1);
        idx_end = times(i) + epoch_samps(2);
        
        if idx_start > 0 && idx_end <= length(eegmu2)
            raw_epoch = eegmu2(idx_start:idx_end, :);
            
            % Baseline Correction (first 100ms which is index 1 to base_samps)
            baseline = mean(raw_epoch(1:base_samps, :), 1);
            epoch_bc = raw_epoch - baseline;
            
            % Accumulate for averaging
            if code == 4 % Congruent
                sum_cong = sum_cong + epoch_bc;
                n_cong = n_cong + 1;
                RT_cong = [RT_cong, rt];
            elseif code == 5 % Incongruent
                sum_incong = sum_incong + epoch_bc;
                n_incong = n_incong + 1;
                RT_incong = [RT_incong, rt];
            end
        end
    end
end

% Calculate Grand Averages
avg_cong = sum_cong / n_cong;
avg_incong = sum_incong / n_incong;
avg_joint = (sum_cong + sum_incong) / (n_cong + n_incong);

% Filter the Averages
avg_cong_filt = filtfilt(b, a, avg_cong);
avg_incong_filt = filtfilt(b, a, avg_incong);
avg_joint_filt = filtfilt(b, a, avg_joint);

%% 1. PLOT ERPs (Fz, Cz, Pz)
% Map: 1:F3, 2:Fz, 3:F4, 4:C3, 5:Cz, 6:C4, 7:P3, 8:Pz, 9:P4, 10:O1, 11:O2, 12:T3, 13:T4, 14:T5/T6?
% Wait, manual says "same order as presented in Lab 2". 
% Usually: F3, Fz, F4, T3, C3, Cz, C4, T4, P3, Pz, P4, O1, O2... (13 chans?)
% Let's assume indices for Fz=2, Cz=5, Pz=8 based on typical arrays or check Lab 2 guide.
% If eegmu2 has 14 cols, let's assume specific columns. 
% *Assumption for plot*: Fz=Channel 2, Cz=Channel 5, Pz=Channel 8 (Standard subset).

figure('Name','VSTM ERPs');
ch_plot = [2, 5, 8]; 
labels = {'Fz', 'Cz', 'Pz'};

for k=1:3
    subplot(3,1,k); hold on;
    plot(t_axis, avg_cong_filt(:, ch_plot(k)), 'b', 'LineWidth', 1.5);
    plot(t_axis, avg_incong_filt(:, ch_plot(k)), 'r', 'LineWidth', 1.5);
    plot(t_axis, avg_joint_filt(:, ch_plot(k)), 'k--', 'LineWidth', 1);
    xline(0, 'k-');
    title(['VSTM P300 - Channel ' labels{k}]);
    legend('Congruent','Incongruent','Joint');
    grid on; xlim([-0.1 1.0]);
end
saveas(gcf, 'VSTM_ERPs.png');

%% 2. TOPOGRAMS
% P3 Window: 250ms to 400ms.
% t_axis starts at -0.1. Index for 0.25 is where t >= 0.25
t_idx = find(t_axis >= 0.25 & t_axis <= 0.40);

% Find max peak in this window for each channel
peaks_cong = max(avg_cong_filt(t_idx, :), [], 1);
peaks_incong = max(avg_incong_filt(t_idx, :), [], 1);
peaks_joint = max(avg_joint_filt(t_idx, :), [], 1);

figure('Name', 'VSTM Topograms');
subplot(1,3,1); draw_topogram2(peaks_cong); title('Congruent');
subplot(1,3,2); draw_topogram2(peaks_incong); title('Incongruent');
subplot(1,3,3); draw_topogram2(peaks_joint); title('Joint');
saveas(gcf, 'VSTM_Topos.png');

%% 3. BEHAVIORAL METRICS (Display in Command Window)
fprintf('=== Student 2 Behavioral ===\n');
fprintf('Congruent: RT = %.3f ± %.3f s\n', mean(RT_cong), std(RT_cong));
fprintf('Incongruent: RT = %.3f ± %.3f s\n', mean(RT_incong), std(RT_incong));

% NOTE: To get % correct, you need to count ALL events 4 and 5, 
% not just the ones followed by 1.
total_cong = sum(trigs == 4);
total_incong = sum(trigs == 5);
% correct_cong is n_cong (calculated in loop)
% correct_incong is n_incong (calculated in loop)

fprintf('Accuracy Congruent: %.2f%%\n', (n_cong/total_cong)*100);
fprintf('Accuracy Incongruent: %.2f%%\n', (n_incong/total_incong)*100);