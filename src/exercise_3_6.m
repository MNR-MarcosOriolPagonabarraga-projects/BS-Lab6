clear; clc; close all;

name = 'V13PLA.CNT';

channels = [5, 14, 23];
chan_names = {'Fz','Cz','Pz'};

% Stimulus-locked pairs
pair_cong = [1 1; 3 8];
pair_incong = [2 1; 4 8];

% Response-locked triplet
triplet_all = [1 8 1; 2 8 1; 3 1 8; 4 1 8];

sigmas = [0, 10, 20];

%% STIMULUS-LOCKED (CONGRUENT + INCONGRUENT)

for c = 1:3
    
    figure;
    sgtitle(['Stimulus-Locked — Channel ' chan_names{c}]);

    % CONGRUENT
    subplot(2,1,1); hold on;
    title('Congruent — Effect of Misalignment');
    for s = 1:length(sigmas)
        tbl = promedioStimulusLockedv2(name, pair_cong, channels(c), sigmas(s));
        avg = mean(tbl,1);
        plot(avg, 'DisplayName',['\sigma = ' num2str(sigmas(s))]);
    end
    xlabel('Samples'); ylabel('Amplitude [\muV]');
    legend; grid on;

    % INCONGRUENT
    subplot(2,1,2); hold on;
    title('Incongruent — Effect of Misalignment');
    for s = 1:length(sigmas)
        tbl = promedioStimulusLockedv2(name, pair_incong, channels(c), sigmas(s));
        avg = mean(tbl,1);
        plot(avg, 'DisplayName',['\sigma = ' num2str(sigmas(s))]);
    end
    xlabel('Samples'); ylabel('Amplitude [\muV]');
    legend; grid on;
end

%% RESPONSE-LOCKED (ERN)

for c = 1:3
    
    figure;
    hold on;
    title(['Response-Locked ERN — Channel ' chan_names{c}]);

    for s = 1:length(sigmas)
        tbl = promedioResponseLockedv2(name, triplet_all, channels(c), sigmas(s));
        avg = mean(tbl,1);
        plot(avg, 'DisplayName',['\sigma = ' num2str(sigmas(s))]);
    end

    xlabel('Samples'); ylabel('Amplitude [\muV]');
    legend; grid on;
end
