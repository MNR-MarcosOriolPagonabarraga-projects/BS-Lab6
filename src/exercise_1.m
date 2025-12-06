clear; clc; close all;

name = 'data/V13PLA.CNT';
channels = [5, 14, 23];    % Fz, Cz, Pz
chan_names = {'Fz','Cz','Pz'};

% Congruent
pair_cong = [1 1; 3 8];

% Incongruent
pair_incong = [2 1; 4 8];

triplet_all = [1 8 1; 2 8 1; 3 1 8; 4 1 8];

%% First 5 epochs - Stimulus Locked

for c = 1:length(channels)

    % CONGRUENT
    table_cong = promedioStimulusLocked(name, pair_cong, channels(c));
    figure;
    subplot(2,1,1);
    hold on;
    title(['Stimulus-Locked — Congruent — Channel ' chan_names{c}]);

    for k = 1:5
        plot(table_cong(k,:));
    end
    xlabel('Samples');
    ylabel('Amplitude [µV]');
    legend('1','2','3','4','5');
    hold off;

    % INCONGRUENT
    table_inc = promedioStimulusLocked(name, pair_incong, channels(c));
    subplot(2,1,2);
    hold on;
    title(['Stimulus-Locked — Incongruent — Channel ' chan_names{c}]);

    for k = 1:5
        plot(table_inc(k,:));
    end
    xlabel('Samples');
    ylabel('Amplitude [µV]');
    legend('1','2','3','4','5');
    hold off;
end


%% First 5 epochs - Response Locked (ERN)

for c = 1:length(channels)

    table_resp = promedioResponseLocked(name, triplet_all, channels(c));

    figure;
    hold on;
    title(['Response-Locked — ERN — Channel ' chan_names{c}]);

    for k = 1:5
        plot(table_resp(k,:));
    end
    xlabel('Samples');
    ylabel('Amplitude [µV]');
    legend('1','2','3','4','5');
    hold off;

end
