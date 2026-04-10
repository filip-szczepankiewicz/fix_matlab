function h = pointsOnSphere(dirs, varargin)
% function h = fix.plot.pointsOnSphere(dirs, varargin)
% Plot gradient directions as spheres on a unit sphere.
%
%   plot_gdirs(dirs)
%   plot_gdirs(dirs, Name, Value, ...)
%
%   Required input:
%     dirs        [N×3]  Direction vectors (need not be unit-norm)
%
%   Optional Name-Value pairs:
%     'Color'         [N×3] or [1×3] RGB color per direction. Default: gray.
%     'Alpha'         Scalar face alpha for direction spheres. Default: 0.9.
%     'Antipodal'     Logical. Also plot antipodal directions. Default: false.
%     'BallRadius'    Scalar. Radius of direction indicator balls relative
%                     to sphere radius. Default: 0.04.
%     'SphereColor'   [1×3] RGB color of the background sphere. Default: [0.85 0.85 0.85].
%     'SphereAlpha'   Scalar face alpha for background sphere. Default: 0.5.
%     'SphereRes'     Integer. Sphere surface resolution. Default: 60.
%     'Lighting'      Logical. Enable Phong lighting. Default: true.
%     'Parent'        Axes handle to plot into. Default: current axes.
%
%   Output:
%     h             Struct of graphics handles (sphere, balls, axes).
%
%   Example:
%     dirs = randn(30, 3);
%     dirs = dirs ./ vecnorm(dirs, 2, 2);
%     plot_gdirs(dirs, 'Antipodal', true, 'Color', [0.2 0.5 0.9]);

p = inputParser;
addRequired(p,  'dirs');
addParameter(p, 'Color',       [],              @(x) isnumeric(x));
addParameter(p, 'Alpha',       0.9,             @(x) isscalar(x) && x>=0 && x<=1);
addParameter(p, 'Antipodal',   false,           @islogical);
addParameter(p, 'BallRadius',  0.04,            @(x) isscalar(x) && x>0);
addParameter(p, 'SphereColor', [1 1 1]*0.85,    @(x) isnumeric(x) && numel(x)==3);
addParameter(p, 'SphereAlpha', 0.5,             @(x) isscalar(x) && x>=0 && x<=1);
addParameter(p, 'SphereRes',   60,              @(x) isscalar(x) && x>0);
addParameter(p, 'Lighting',    false,           @islogical);
addParameter(p, 'Parent',      [],              @(x) isempty(x) || isa(x,'matlab.graphics.axis.Axes'));
parse(p, dirs, varargin{:});
opt = p.Results;

N   = size(dirs, 1);
R   = max(vecnorm(dirs, 2, 2));   % enclosing radius
r   = opt.BallRadius * R;

% Resolve color: [N×3]
col = opt.Color;
if isempty(col)
    col = repmat([0.5 0.5 0.5], N, 1);
elseif size(col,1) == 1
    col = repmat(col(1,1:3), N, 1);
elseif size(col,1) ~= N
    error('plot_gdirs: ''Color'' must be [1×3] or [N×3].');
else
    col = col(:, 1:3);
end

% Select or create axes
if isempty(opt.Parent)
    ax = gca;
else
    ax = opt.Parent;
end
hold(ax, 'on');

% Background sphere
[xs, ys, zs] = sphere(opt.SphereRes);
h.sphere = surface(ax, xs*R, ys*R, zs*R, ...
    'FaceColor', opt.SphereColor, ...
    'FaceAlpha', opt.SphereAlpha, ...
    'LineStyle', 'none', ...
    'Tag',       'gdirs_sphere');

% Direction balls
[xb, yb, zb] = sphere(20);
h.balls = gobjects(N, 1);
for i = 1:N
    xp = xb*r + dirs(i,1);
    yp = yb*r + dirs(i,2);
    zp = zb*r + dirs(i,3);
    h.balls(i) = surface(ax, xp, yp, zp, ...
        'FaceColor', col(i,:), ...
        'FaceAlpha', opt.Alpha, ...
        'LineStyle', 'none', ...
        'Tag',       'gdirs_ball');
    if opt.Antipodal
        surface(ax, -xp, -yp, -zp, ...
            'FaceColor', col(i,:), ...
            'FaceAlpha', opt.Alpha * 0.6, ...
            'LineStyle', 'none', ...
            'Tag',       'gdirs_antipodal');
    end
end

% Axes appearance
lim = R * 1.15;
axis(ax, [-lim lim -lim lim -lim lim]);
axis(ax, 'vis3d', 'equal', 'off');

if opt.Lighting
    lighting(ax, 'phong');
    camlight(ax, -30, -30);
    camlight(ax,  30, -60);
    material(ax, 'dull');
end

h.axes = ax;
end