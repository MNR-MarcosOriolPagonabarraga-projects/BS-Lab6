clear; clc; close all;

name = 'data/V13PLA.CNT';
fs = 250;

chan_indices = [1, 2, 3, 4, 5, 6, 7, 12, 13, 14, 15, 16, 21, 22, 23, 24, 25, 28, 29];
num_topo_chans = length(chan_indices);

pair_cong   = [1 1; 3 8];
pair_incong = [2 1; 4 8];
triplet_all = [1 8 1; 2 8 1; 3 1 8; 4 1 8];

% Windows
P3_win = round([0.250 0.600] * fs);
ERN_win = round([0 0.100] * fs);
zero_pt = 101; 

P3_peaks_cong = zeros(1, num_topo_chans);
P3_peaks_incong = zeros(1, num_topo_chans);
ERN_peaks = zeros(1, num_topo_chans);

%% CALCULATE PEAKS
fprintf('Calculating Topography Data...\n');

for k = 1:num_topo_chans
    ch = chan_indices(k);
    
    % P3 Congruent
    data = promedioStimulusLocked(name, pair_cong, ch);
    avg = mean(data, 1);

    win_idx = (zero_pt + P3_win(1)) : (zero_pt + P3_win(2));
    P3_peaks_cong(k) = max(avg(win_idx));
    
    % P3 Incongruent
    data = promedioStimulusLocked(name, pair_incong, ch);
    avg = mean(data, 1);
    P3_peaks_incong(k) = max(avg(win_idx));
    
    % ERN (Absolute Value)
    data = promedioResponseLocked(name, triplet_all, ch);
    avg = mean(data, 1);

    win_idx = (zero_pt + ERN_win(1)) : (zero_pt + ERN_win(2));
    ERN_peaks(k) = abs(min(avg(win_idx)));
end

%% PLOT TOPOGRAMS
figure('Name', 'Topographic Distributions', 'Color', 'w');

subplot(1,3,1);
draw_topogram(P3_peaks_cong');
title('P3 Amplitude (Congruent)', FontSize=16);

subplot(1,3,2);
draw_topogram(P3_peaks_incong');
title('P3 Amplitude (Incongruent)', FontSize=16);

subplot(1,3,3);
draw_topogram(ERN_peaks');
title('|ERN| Amplitude', FontSize=16);

saveas(gcf, 'Topo_Comparison.png');