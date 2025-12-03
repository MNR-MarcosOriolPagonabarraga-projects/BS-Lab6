function draw_topogram2(data, limits, ax, cmap)

% DRAW_TOPOGRAM   Draws a 14-channel topographic map of OpenBCI EEG signals
%
% Example1:
%
%     figure; draw_topogram([0 0 3 4 4 3 2 2 9 2 2 7 7 15]');
%
% Example2:
%
%     cmap = [0.1 0.1 0.4; 
%             0.4 0.4 0.6;
%             0.7 0.7 0.8;
%             1.0 1.0 1.0;
%             0.8 0.7 0.7;
%             0.6 0.4 0.4;
%             0.4 0.1 0.1];
%     figure;
%     ax1 = subplot(211);
%     ax2 = subplot(212); plot(rand(5));
%     draw_topogram([0 0 1 3 1 0 2 3 0 -1 -1 -3 -1 -2]', [-3 3], ax1, cmap);
%
%     This last example is a statistical probability map where values 0, 1,
%     2 and 3 represent different p-values (no significance, tendence, significant 
%     difference and very significant difference, respectively). Sign
%     indicates direction of the detected change.
%
%

% CREATED:   2003.12, Joan F. Alonso
% BASED On:  Topoplot 2.1, Colin Humphries
%
% REVISED:   2020.09, Joan F. Alonso
% Changes:   Adaptated to teaching use, 19 channels only (10/20 system)
%
% REVISED:   2024.12, Joan F. Alonso
% Changes:   Adaptated to teaching use, 14 channels (OpenBCI system)

%% ELECTRODE DATA
names =  {'Fp1';  'Fp2'; 'F7';  'F3'; 'Fz'; 'F4'; 'F8';  'C3'; 'Cz'; 'C4';   'P3';  'Pz';  'P4';  'Oz'};
angles = {-15.0;  15.0; -47.1; -36.5;  0.0; 36.5; 47.1; -85.9;  0.0; 85.9; -140.0; 180.0; 140.0; 180.0};
radii =  { .475;  .475;  .475;  .335; .250; .335; .475;  .245; .014; .245;   .335;  .250;  .335;  .475};
ELECTRODES = struct('nom', cellstr(names), 'numero', num2cell((1:numel(names))'), 'angle', angles, 'radi', radii);
clear('names', 'angles', 'radii');


%% ARGUMENT CHECKING
narginchk(1, 4);
nargoutchk(0, 0);

if nargin < 3 || isempty(ax)
  ax = gca;
end

if nargin > 3
  set(get(ax, 'Parent'), 'Colormap', cmap);
end

[ch_number, columns] = size(data);

switch columns
  case 1
    % Mode estàndard
    if ch_number ~= numel(ELECTRODES)
      error(generatemsgid('Number of rows must be 19'));
    end
  otherwise
    error(generatemsgid('Please provide data in a single column'));
end


%% DEFINITIONS
max_radius = .5;
delta = max_radius/100;


%% CONVERSION TO CARTESIAN COORDINATES
[x,y] = pol2cart(pi/180*[ELECTRODES(:).angle]',[ELECTRODES(:).radi]');


%% DRAW MAP
cla(ax); set(ax, 'NextPlot', 'Add');

% Coordinate matrix to interpolate
[xi, yi] = meshgrid(linspace(-max_radius, max_radius, 1/delta), linspace(-max_radius,        ...
max_radius, 1/delta));

% Interpolation
zi = griddata(y, x, data, xi, yi, 'v4'); %#ok<GRIDD>
zi(not(xi.*xi+yi.*yi <= max_radius*max_radius)) = NaN;

% Drawing
surface(xi-delta/2, yi-delta/2, zeros(size(zi)), zi, 'EdgeColor', 'none', 'FaceColor',    ...
'interp', 'Parent', ax);
if nargin < 2 || isempty(limits)
    caxis(ax, [min(min(zi)) max(max(zi))]);
else
    caxis(ax, [limits(1) limits(2)]);
end

% Plot electrodes on top
for i = 1 : numel(ELECTRODES)
  plot(y(i), x(i), 'o', 'LineWidth', 2, 'MarkerFaceColor', [0.5 0.5 0.5],                  ...
    'MarkerEdgeColor', [0 0 0], 'MarkerSize', 5, 'Parent', ax);
end

% Draw head, nose and ears
set(ax, 'Xlim', [-.6 .6], 'Ylim', [-.6 .6]);
l     = 0:2*pi/3600:2*pi;
tip   = max_radius*1.08;
base  = max_radius-.006;
ear_x = [.4972 .5028 .5106 .5208 .5308 .5348 .5344 .5295 .5289 .5308 .5340 .5369 .5329       ...
  .5240 .5091 .4947 .4875];
ear_y = [.0555 .0663 .0716 .0712 .0595 .0366 .0052 -.0141 -.0365 -.0617 -.0828 -.1070 -.1295 ...
  -.1358 -.1367 -.1268 -.1106];
plot(cos(l).*max_radius-0.002, sin(l).*max_radius-0.003, 'color', [0.5 0.5 0.5],             ...
  'Linestyle', '-', 'LineWidth', 3, 'Parent', ax);
plot([.14*max_radius; 0; -.14*max_radius], [base; tip; base], 'Color', [0.5 0.5 0.5],        ...
  'LineWidth', 3, 'Parent', ax);
plot( ear_x, ear_y, 'color', [0.5 0.5 0.5], 'LineWidth', 3, 'Parent', ax);
plot(-ear_x-0.004, ear_y, 'color', [0.5 0.5 0.5], 'LineWidth', 3, 'Parent', ax);
axis(ax, 'square', 'off');
drawnow;