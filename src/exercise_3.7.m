%% ===============================================================
%  EXERCISE 3.7 — TOPOGRAPHIC DISTRIBUTION
%  P3 (Congruent/Incongruent) and ERN (Correction)
% ===============================================================

clear; clc; close all;

name = 'V13PLA.CNT';
fs = 250;

% Standard 19 channels indices based on leercnt.m output order:
% Fp1, Fp2, F7, F3, Fz, F4, F8, T3, C3, Cz, C4, T4, T5, P3, Pz, P4, T6, O1, O2
% Check leercnt to confirm: 1=Fp1, 2=Fp2, 3=F7, 4=F3, 5=Fz, 6=F4, 7=F8, 
% 12=T3, 13=C3, 14=Cz, 15=C4, 16=T4, 21=T5, 22=P3, 23=Pz, 24=P4, 25=T6, 28=O1, 29=O2
chan_indices = [1, 2, 3, 4, 5, 6, 7, 12, 13, 14, 15, 16, 21, 22, 23, 24, 25, 28, 29];
num_topo_chans = length(chan_indices);

% Pairs/Triplets
pair_cong   = [1 1; 3 8];
pair_incong = [2 1; 4 8];
triplet_all = [1 8 1; 2 8 1; 3 1 8; 4 1 8];

% Windows
P3_win = round([0.250 0.600] * fs); % Relative to stimulus (index 101)
ERN_win = round([0 0.100] * fs);    % Relative to response (index 101)
zero_pt = 101; 

P3_peaks_cong = zeros(1, num_topo_chans);
P3_peaks_incong = zeros(1, num_topo_chans);
ERN_peaks = zeros(1, num_topo_chans);

%% 1. CALCULATE PEAKS
fprintf('Calculating Topography Data...\n');

for k = 1:num_topo_chans
    ch = chan_indices(k);
    
    % --- P3 Congruent ---
    data = promedioStimulusLocked(name, pair_cong, ch);
    avg = mean(data, 1);
    % Max between 250-600ms
    win_idx = (zero_pt + P3_win(1)) : (zero_pt + P3_win(2));
    P3_peaks_cong(k) = max(avg(win_idx));
    
    % --- P3 Incongruent ---
    data = promedioStimulusLocked(name, pair_incong, ch);
    avg = mean(data, 1);
    P3_peaks_incong(k) = max(avg(win_idx));
    
    % --- ERN (Absolute Value) ---
    data = promedioResponseLocked(name, triplet_all, ch);
    avg = mean(data, 1);
    % Max absolute negative peak between 0-100ms
    win_idx = (zero_pt + ERN_win(1)) : (zero_pt + ERN_win(2));
    ERN_peaks(k) = abs(min(avg(win_idx))); % Taking absolute value as requested
end

%% 2. PLOT TOPOGRAMS
figure('Name', 'Topographic Distributions', 'Color', 'w');

subplot(1,3,1);
draw_topogram(P3_peaks_cong);
title('P3 Amplitude (Congruent)');

subplot(1,3,2);
draw_topogram(P3_peaks_incong);
title('P3 Amplitude (Incongruent)');

subplot(1,3,3);
draw_topogram(ERN_peaks);
title('|ERN| Amplitude');

% Save the figure manually or via code
saveas(gcf, 'Topo_Comparison.png');
fprintf('Done.\n');