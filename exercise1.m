%% Load data
eegStruct = load("data/student2.mat");
fs = eegStruct.fs;
eeg = eegStruct.eegmu2;


%% Visualize

time = (0:length(eeg)-1) / fs; % Create time vector based on sampling frequency
plot(time, eeg); % Plot the EEG signal
xlabel('Time (s)');
ylabel('EEG Signal');
title('EEG Signal Visualization');