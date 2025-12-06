clear; clc; close all;

name = 'V13PLA.CNT';

% Channels Fz, Cz, Pz
channels = [5, 14, 23];
ch_names = {'Fz','Cz','Pz'};

% Stimulus-locked pairs
pair_cong  = [1 1; 3 8];
pair_incong = [2 1; 4 8];

% Response-locked triplet
triplet = [1 8 1; 2 8 1; 3 1 8; 4 1 8];

% Number of trials
N_list = [10, 20, 30, 40];

%% Stimulus-Locked - Congruent & Incongruent

for c = 1:length(channels)

    % Load epochs
    table_cong   = promedioStimulusLocked(name, pair_cong, channels(c));
    table_incong = promedioStimulusLocked(name, pair_incong, channels(c));

    % CONGRUENT
    figure;
    subplot(2,1,1); hold on;
    title(['Stimulus-Locked Averages — Congruent — ' ch_names{c}]);

    % Progressive averages
    for k = 1:length(N_list)
        avgN = mean(table_cong(1:N_list(k), :), 1);
        plot(avgN, 'DisplayName', ['N=' num2str(N_list(k))]);
    end

    % Full average
    plot(mean(table_cong,1), 'k', 'LineWidth', 1.7, 'DisplayName','All trials');
    xlabel('Samples'); ylabel('Amplitude [µV]'); legend;

    % INCONGRUENT
    subplot(2,1,2); hold on;
    title(['Stimulus-Locked Averages — Incongruent — ' ch_names{c}]);

    for k = 1:length(N_list)
        avgN = mean(table_incong(1:N_list(k), :), 1);
        plot(avgN, 'DisplayName', ['N=' num2str(N_list(k))]);
    end

    plot(mean(table_incong,1), 'k', 'LineWidth', 1.7, 'DisplayName','All trials');
    xlabel('Samples'); ylabel('Amplitude [µV]'); legend;

end

%% Response-Locked - ERN

for c = 1:length(channels)

    table_resp = promedioResponseLocked(name, triplet, channels(c));

    figure; hold on;
    title(['Response-Locked Averages — ERN — ' ch_names{c}]);

    for k = 1:length(N_list)
        avgN = mean(table_resp(1:N_list(k), :), 1);
        plot(avgN, 'DisplayName', ['N=' num2str(N_list(k))]);
    end

    plot(mean(table_resp,1), 'k', 'LineWidth', 1.7, 'DisplayName','All trials');
    xlabel('Samples'); ylabel('Amplitude [µV]'); legend;

end

