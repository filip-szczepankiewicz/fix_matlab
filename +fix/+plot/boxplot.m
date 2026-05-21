function h = my_boxplot(x, H, opt)
% function h = my_boxplot(x, H, opt)
%
% Custom boxplot with filled IQR box, whiskers, and outlier markers.
%
% Usage
%   my_boxplot(H)             % x = 1:ncols
%   my_boxplot(x, H)          % explicit x positions
%   my_boxplot(x, H, opt)     % custom options struct
%
%   opt = my_boxplot()        % return default options

arguments (Input)
    x    = []
    H    = []
    opt  struct = struct()
end

% ── Defaults ──────────────────────────────────────────────────────────────
def.wPct    = [2.5, 97.5];   % whisker percentiles
def.wWidth  = 0.3;           % whisker cap half-width (in x units)
def.wLW     = 1.0;           % whisker line width
def.wCol    = 'k';           % whisker colour
def.boxW    = 0.6;           % box full-width (in x units)
def.boxCol  = [0.7 0.8 0.9]; % box fill colour
def.boxEdge = 'k';           % box edge colour
def.boxLW   = 1.0;           % box edge line width
def.medCol  = 'k';           % median line colour
def.medLW   = 2.0;           % median line width
def.outMrk  = 'o';           % outlier marker symbol
def.outSize = 4;             % outlier marker size
def.outCol  = 'k';           % outlier marker edge colour
def.outFill = 'none';        % outlier marker face colour

% Return defaults if called with no arguments
if isempty(x) && isempty(H)
    h = def;
    return
end

% Merge user options over defaults
opt = mergeOpt(def, opt);

% Allow my_boxplot(H) with no x
if isempty(H)
    H = x;
    x = 1:size(H, 2);
end

x = x(:)';
if isvector(H)
    H = H(:);
end

% ── Statistics ────────────────────────────────────────────────────────────
wLo  = prctile(H, opt.wPct(1));
wHi  = prctile(H, opt.wPct(2));
q25  = prctile(H, 25);
q75  = prctile(H, 75);
med  = median(H, 'omitnan');

% ── Draw ──────────────────────────────────────────────────────────────────
hold on
hw = opt.boxW   / 2;   % half box width
cw = opt.wWidth / 2;   % half cap width

h = struct('box', [], 'whiskerLo', [], 'whiskerHi', [], ...
           'capLo', [], 'capHi', [], 'median', [], 'outliers', []);

for i = 1:numel(x)
    cx = x(i);
    col = H(:, i);

    % Filled IQR box
    bx = cx + [-1 1 1 -1 -1] * hw;
    by = [q25(i) q25(i) q75(i) q75(i) q25(i)];
    h.box(i) = patch(bx, by, opt.boxCol, ...
        'EdgeColor', opt.boxEdge, ...
        'LineWidth', opt.boxLW);

    % Whiskers
    h.whiskerLo(i) = plot([cx cx], [wLo(i) q25(i)], '-', ...
        'Color', opt.wCol, 'LineWidth', opt.wLW);
    h.whiskerHi(i) = plot([cx cx], [q75(i) wHi(i)], '-', ...
        'Color', opt.wCol, 'LineWidth', opt.wLW);

    % Caps
    h.capLo(i) = plot(cx + [-1 1]*cw, [wLo(i) wLo(i)], '-', ...
        'Color', opt.wCol, 'LineWidth', opt.wLW);
    h.capHi(i) = plot(cx + [-1 1]*cw, [wHi(i) wHi(i)], '-', ...
        'Color', opt.wCol, 'LineWidth', opt.wLW);

    % Median
    h.median(i) = plot(cx + [-1 1]*hw, [med(i) med(i)], '-', ...
        'Color', opt.medCol, 'LineWidth', opt.medLW);

    % Outliers: points outside the whisker percentiles
    out = col(col < wLo(i) | col > wHi(i));
    if ~isempty(out)
        h.outliers(end+1) = plot(repmat(cx, size(out)), out, ...
            opt.outMrk, ...
            'MarkerSize',      opt.outSize, ...
            'MarkerEdgeColor', opt.outCol, ...
            'MarkerFaceColor', opt.outFill, ...
            'LineStyle',       'none');
    end
end
end


function opt = mergeOpt(def, usr)
opt = def;
f   = fieldnames(usr);
for k = 1:numel(f)
    if isfield(def, f{k})
        opt.(f{k}) = usr.(f{k});
    else
        warning('my_boxplot: unknown option ''%s'' ignored', f{k});
    end
end
end