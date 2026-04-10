function h = lineArea(x, y, y_lo, y_hi, varargin)
% function h = lineArea(x, y, y_lo, y_hi, varargin)
%
% Usage:
%   h = plot_shaded(x, y, y_lo, y_hi)
%   h = plot_shaded(x, y, y_lo, y_hi, Name, Value, ...)
%
% Inputs:
%   x     - [1×N] or [N×1] vector of x values
%   y     - [1×N] or [N×1] vector of y values (typically the median)
%   y_lo  - [1×N] or [N×1] lower bound (e.g. Q1, 25th percentile)
%   y_hi  - [1×N] or [N×1] upper bound (e.g. Q3, 75th percentile)
%
% Optional Name-Value pairs:
%   'Color'         - Line/shading color, default: current axes color order
%   'LineWidth'     - Line width, default: 1.5
%   'LineStyle'     - Line style, default: '-'
%   'ShadeAlpha'    - Shading transparency [0,1], default: 0.2
%   'ShadeColor'    - Shading color (if different from line), default: same as 'Color'
%   'Parent'        - Target axes, default: gca

p = inputParser;
addRequired(p, 'x');
addRequired(p, 'y');
addRequired(p, 'y_lo');
addRequired(p, 'y_hi');
addParameter(p, 'Color',      []);
addParameter(p, 'LineWidth',  1.5);
addParameter(p, 'LineStyle',  '-');
addParameter(p, 'ShadeAlpha', 0.2);
addParameter(p, 'ShadeColor', []);
addParameter(p, 'Parent',     []);
parse(p, x, y, y_lo, y_hi, varargin{:});
opt = p.Results;

% --- Target axes ---
if isempty(opt.Parent)
    ax = gca;
else
    ax = opt.Parent;
end

% --- Flatten to row vectors ---
x    = x(:)';
y    = y(:)';
y_lo = y_lo(:)';
y_hi = y_hi(:)';
N    = numel(x);

assert(numel(y_lo) == N && numel(y_hi) == N, ...
    'plot_shaded: x, y, y_lo, y_hi must all have the same number of elements.');

% --- Clamp lower bound if log scale ---
if strcmp(ax.YScale, 'log')
    min_positive = min(y(y > 0), [], 'all');
    if isempty(min_positive), min_positive = 1e-10; end
    y_lo = max(y_lo, min_positive * 1e-3);
end

% --- Color ---
if isempty(opt.Color)
    co      = ax.ColorOrder;
    idx     = mod(ax.ColorOrderIndex - 1, size(co, 1)) + 1;
    opt.Color = co(idx, :);
end
if isempty(opt.ShadeColor)
    opt.ShadeColor = opt.Color;
end

% --- Draw ---
wasHeld = ishold(ax);
hold(ax, 'on');

x_patch = [x, fliplr(x)];
y_patch = [y_lo, fliplr(y_hi)];

h.patch = fill(ax, x_patch, y_patch, opt.ShadeColor, ...
    'FaceAlpha', opt.ShadeAlpha, ...
    'EdgeColor', 'none', ...
    'HandleVisibility', 'off');

h.line = plot(ax, x, y, ...
    'Color',     opt.Color, ...
    'LineWidth', opt.LineWidth, ...
    'LineStyle', opt.LineStyle);

if ~wasHeld
    hold(ax, 'off');
end