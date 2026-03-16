function spiderplot(data, varargin)
% function fix.plot.spiderplot(data, varargin)
% SPIDER_PLOT  Radar/spider chart with n spokes and m transparent surfaces.
% By Claude AI and Filip Sz
%
%   spider_plot(data)
%   spider_plot(data, Name, Value, ...)
%
%   INPUT
%   -----
%   data  : n x m numeric matrix
%             n rows  = number of spokes (axes / variables)
%             m cols  = number of data series (surfaces / overlays)
%
%   NAME-VALUE PAIRS (all optional)
%   --------------------------------
%   'Labels'      cell array of n strings   spoke labels (shown at outer tip)
%   'SeriesNames' cell array of m strings   legend entries
%   'Limits'      n x 2 matrix             [min max] per spoke;
%                                           default: auto from data range
%   'Colors'      m x 3 RGB matrix          surface fill colours
%   'FillAlpha'   scalar in [0,1]           transparency of fills (0.15)
%   'LineWidth'   scalar                    series outline width (1.5)
%   'GridLevels'  integer                   concentric polygon rings (5)
%   'Title'       string                    figure title
%
%   EXAMPLE
%   -------
%   data = randn(5, 3);
%   fix.plot.spiderplot(data, ...
%       'Labels',      {'Speed','Power','Accuracy','Endurance','Agility'}, ...
%       'SeriesNames', {'Case A','Case B','Case C'}, ...
%       'Title',       'Performance');

% ── parse inputs ──────────────────────────────────────────────────────────
p = inputParser;
addRequired(p,  'data',        @(x) isnumeric(x) && ismatrix(x));
addParameter(p, 'Labels',      {},    @iscell);
addParameter(p, 'SeriesNames', {},    @iscell);
addParameter(p, 'Limits',      [],    @(x) isnumeric(x));
addParameter(p, 'Colors',      [],    @(x) isnumeric(x));
addParameter(p, 'FillAlpha',   0.15,  @(x) isscalar(x) && x>=0 && x<=1);
addParameter(p, 'LineWidth',   1.5,   @isscalar);
addParameter(p, 'GridLevels',  5,     @(x) isscalar(x) && x>=1);
addParameter(p, 'Title',       '',    @ischar);
addParameter(p, 'do_turn',       1,   @isscalar);
addParameter(p, 'markerSize',    0,   @isscalar);
parse(p, data, varargin{:});
opt = p.Results;

[n, m] = size(data);

% ── default labels ────────────────────────────────────────────────────────
if isempty(opt.Labels)
    opt.Labels = arrayfun(@(k) sprintf('Var %d', k), 1:n, 'UniformOutput', false);
end
if isempty(opt.SeriesNames)
    opt.SeriesNames = arrayfun(@(k) sprintf('Series %d', k), 1:m, 'UniformOutput', false);
end

% ── limits and normalisation ──────────────────────────────────────────────
% limits(:,1) = lo  →  normalised radius 0  (inner ring)
% limits(:,2) = hi  →  normalised radius 1  (outer ring)
%
% When Limits is not supplied the min and max are taken across all series
% for each spoke independently, so the outer ring always touches the most
% extreme data point on every axis.
if isempty(opt.Limits)
    lo = 0;   % n x 1
    hi = max(data(:));   % n x 1
else
    if ~isequal(size(opt.Limits), [n 2])
        error('spider_plot: ''Limits'' must be an [%d x 2] matrix.', n);
    end
    lo = opt.Limits(:,1);
    hi = opt.Limits(:,2);
    if any(lo >= hi)
        error('spider_plot: Each row of Limits must satisfy Limits(k,1) < Limits(k,2).');
    end
end

span = hi - lo;
span(span == 0) = 1;                      % guard: constant spoke
norm_data = (data - lo) ./ span;          % n x m  (0 = lo, 1 = hi)
% Note: values outside [lo,hi] will plot outside the outer ring, which is
% intentional so out-of-range data is visible.

% ── colours ───────────────────────────────────────────────────────────────
if isempty(opt.Colors)
    opt.Colors = lines(m);
end

% ── spoke angles: top = pi/2, clockwise ───────────────────────────────────
angles = linspace(pi/2, pi/2 - 2*pi, n+1);

if opt.do_turn
    angles = angles + (angles(2)-angles(1))/2;
end

angles = angles(1:end-1);      % n values, no repeated endpoint

% ── figure / axes ─────────────────────────────────────────────────────────
% figure('Color','w','Units','normalized','Position',[0.2 0.15 0.55 0.70]);
ax = axes('Units','normalized','Position',[0.08 0.08 0.84 0.84]);
hold(ax, 'on');
axis(ax, 'equal', 'off');

gridColor = [0.82 0.82 0.82];

% ── polygonal background grid ─────────────────────────────────────────────
% Each ring is a closed n-gon (not a circle), connecting the n spoke tips
% at radius r_g.  This matches the discrete structure of the chart.
for g = 1 : opt.GridLevels
    r_g   = g / opt.GridLevels;
    th_pg = [angles, angles(1)];          % close the polygon
    plot(ax, r_g*cos(th_pg), r_g*sin(th_pg), ...
        'Color', gridColor, 'LineWidth', 0.5);
end

% ── spokes ────────────────────────────────────────────────────────────────
for k = 1 : n
    plot(ax, [0, cos(angles(k))], [0, sin(angles(k))], ...
        'Color', gridColor, 'LineWidth', 0.7);
end

% ── spoke labels: name + max value at the outer tip ───────────────────────
% The value shown next to the label is hi(k), i.e. the value that maps to
% normalised radius = 1.  This is always correct regardless of whether
% Limits was auto-derived or user-supplied.
labelOffset = 1.05;
hLabels = gobjects(n, 1);

for k = 1 : n
    cosA = cos(angles(k));
    sinA = sin(angles(k));

    % Anchor text so it grows away from the centre
    if     abs(cosA) < 0.13,  ha = 'center';
    elseif cosA > 0,           ha = 'left';
    else,                      ha = 'right';
    end
    if     abs(sinA) < 0.13,  va = 'middle';
    elseif sinA > 0,           va = 'bottom';
    else,                      va = 'top';
    end

    % Two-line label: variable name / max value
    labelStr = sprintf('%s', opt.Labels{k});

    hLabels(k) = text(ax, labelOffset*cosA, labelOffset*sinA, labelStr, ...
        'HorizontalAlignment', ha, ...
        'VerticalAlignment',   va, ...
        'FontSize', 9, 'FontWeight', 'bold');
end

% ── pre-compute closed polygon coordinates for every series ───────────────
XV = zeros(n+1, m);
YV = zeros(n+1, m);
for s = 1 : m
    r  = norm_data(:,s)';           % 1 x n
    th = [angles, angles(1)];       % 1 x (n+1)
    rv = [r, r(1)];                 % 1 x (n+1)  – close polygon
    XV(:,s) = (rv .* cos(th))';
    YV(:,s) = (rv .* sin(th))';
end

% ── pass 1: filled patches (all drawn before any line) ────────────────────
for s = 1 : m
    patch(ax, XV(:,s)', YV(:,s)', opt.Colors(s,:), ...
        'FaceAlpha', opt.FillAlpha, ...
        'EdgeColor', 'none');
end

% ── pass 2: outlines + markers (drawn on top of all fills) ────────────────
hLine = gobjects(m,1);
for s = 1 : m
    hLine(s) = plot(ax, XV(:,s)', YV(:,s)', ...
        'Color',     opt.Colors(s,:), ...
        'LineWidth', opt.LineWidth);

    if opt.markerSize
        plot(ax, XV(1:end-1,s)', YV(1:end-1,s)', 'o', ...
            'MarkerFaceColor', opt.Colors(s,:), ...
            'MarkerEdgeColor', 'w', ...
            'MarkerSize', opt.markerSize);
    end
end

% ── legend & title ────────────────────────────────────────────────────────
legend(ax, hLine, opt.SeriesNames, ...
    'Location',    'southoutside', ...
    'Orientation', 'horizontal', ...
    'Box',         'off', ...
    'FontSize',    9);

if ~isempty(opt.Title)
    title(ax, opt.Title, 'FontSize', 13, 'FontWeight', 'bold');
end

% ── dynamic axis limits from rendered label extents ───────────────────────
% drawnow forces MATLAB to compute the Extent property in data units.
drawnow;
xlo = -1.05;  xhi = 1.05;
ylo = -1.05;  yhi = 1.05;
for k = 1 : n
    ext = get(hLabels(k), 'Extent');   % [x  y  width  height]
    xlo = min(xlo, ext(1));
    ylo = min(ylo, ext(2));
    xhi = max(xhi, ext(1) + ext(3));
    yhi = max(yhi, ext(2) + ext(4));
end
margin = 0.06 * max(xhi - xlo, yhi - ylo);
axis(ax, [xlo-margin, xhi+margin, ylo-margin, yhi+margin]);

hold(ax, 'off');
end
