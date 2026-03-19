function h = superQuadratic(B, varargin)
% function h = fix.plot.superQuadratic(B, varargin)
% By Filip Sz and ChatGPT
%
% Usage:
%   plot_btensor_superquadric(B, 'col', [0.7 0.7 0.7], 'eps1',0.8, 'eps2',1.2, 'scale',1, 'scaleMode','linear')
%
% Options (name-value):
%   'level'    : iso-surface level (default 1)           % used only for b-tensor sqrt/inv logic
%   'n'        : resolution (default 80)
%   'alpha'    : face transparency (default 0.95)
%   'col'      : RGB triplet (1x3) or scalar gray (default [0.7 0.7 0.7])
%   'showAxes' : show principal axes (default false)
%   'eps1'     : override epsilon1 (empty = automatic)
%   'eps2'     : override epsilon2 (empty = automatic)
%   'scale'    : overall size multiplier (default 1)
%   'scaleMode': 'linear' | 'sqrt' | 'invSqrt' | 'trace'  (default 'linear')
%
% 'scaleMode' controls how radii are computed from eigenvalues:
%   'linear'  : radii ∝ lambda (what you requested)
%   'sqrt'    : radii ∝ sqrt(lambda)     (diffusion-tensor convention)
%   'invSqrt' : radii ∝ 1/sqrt(lambda)   (b-tensor convention)
%   'trace'   : radii ∝ lambda / sum(lambda) (normalized)
%
% Example:
%   B = diag([1 0.5 0.2]);
%   plot_btensor_superquadric(B, 'col',[0.6 0.6 0.6], 'scale',1.5, 'scaleMode','linear');

% ---- parse inputs
p = inputParser;
addRequired(p,'B',@(x)ismatrix(x)&&all(size(x)==[3 3]));
addParameter(p,'level',1,@(x)isscalar(x)&&x>0);
addParameter(p,'n',80,@(x)isscalar(x)&&x>=8);
addParameter(p,'alpha',0.95,@(x)isscalar(x)&&(x>=0&&x<=1));
addParameter(p,'col',[0.7 0.7 0.7],@(x) (isnumeric(x)&&(numel(x)==3)) || (isscalar(x) && x>=0 && x<=1));
addParameter(p,'showAxes',false,@islogical);
addParameter(p,'eps1',[],@(x) isempty(x) || (isscalar(x) && x>0));
addParameter(p,'eps2',[],@(x) isempty(x) || (isscalar(x) && x>0));
addParameter(p,'scale',1,@(x)isscalar(x)&&x>0);
addParameter(p,'scaleMode','linear',@(s) any(strcmpi(s,{'linear','sqrt','invsqrt','trace'})));
parse(p,B,varargin{:});
opts = p.Results;

% normalize color input
if isscalar(opts.col)
    col = repmat(opts.col,1,3);
else
    col = opts.col(:)'; % ensure row RGB
end

% --- prepare tensor
% B = (B + B.')/2;
[V,D] = eig(B);
lambda = real(diag(D));
lambda(lambda < 0) = 0;

% sort descending
[lambda, idx] = sort(lambda,'descend');
V = V(:, idx);

if all(lambda==0), lambda = [1;1;1]; end

% --- compute default epsilons from shape (Kindlmann-style)
l1=lambda(1); l2=lambda(2); l3=lambda(3);
cl = (l1 - l2) / (l1 + l2 + l3 + eps);
cp = (l2 - l3) / (l1 + l2 + l3 + eps);
default_eps1 = (1 - cl)*1.0 + cl*0.3;
default_eps2 = (1 - cp)*1.0 + cp*0.3;

epsilon1 = opts.eps1;
epsilon2 = opts.eps2;
if isempty(epsilon1), epsilon1 = default_eps1; end
if isempty(epsilon2), epsilon2 = default_eps2; end

% --- compute radii according to selected scale mode
switch lower(opts.scaleMode)
    case 'linear'
        % map largest eigenvalue -> opts.scale
        radii = (lambda / max(lambda + eps)) * opts.scale;
    case 'sqrt'
        radii = sqrt(lambda);
        radii = radii / max(radii + eps) * opts.scale;
    case 'invsqrt'
        radii = 1./sqrt(lambda + eps);
        radii = radii / max(radii + eps) * opts.scale;
    case 'trace'
        radii = (lambda / sum(lambda + eps)) * opts.scale;
    otherwise
        radii = (lambda / max(lambda + eps)) * opts.scale;
end

% --- superquadric mesh
n = opts.n;
[theta,phi] = meshgrid(linspace(-pi,pi,n), linspace(-pi/2,pi/2,n));
f = @(w,e) sign(cos(w)).*abs(cos(w)).^e;
g = @(w,e) sign(sin(w)).*abs(sin(w)).^e;
X = f(phi,epsilon1).*f(theta,epsilon2);
Y = f(phi,epsilon1).*g(theta,epsilon2);
Z = g(phi,epsilon1);

S = [X(:)'; Y(:)'; Z(:)'];
T = V * diag(radii) * S;
Xe = reshape(T(1,:), size(X));
Ye = reshape(T(2,:), size(Y));
Ze = reshape(T(3,:), size(Z));

% --- Plot (force uniform FaceColor to avoid colormap/CData overrides)
if nargout==0
    % figure;
end
hSurf = surf(Xe, Ye, Ze, ...
    'FaceColor', col, ...        % <--- uniform RGB face color (guaranteed)
    'EdgeColor','none', ...
    'FaceAlpha', opts.alpha, ...
    'FaceLighting','gouraud');   % lighting model

axis equal vis3d; hold on;
xlabel('x'); ylabel('y'); zlabel('z');
title('Superquadric glyph');

% Ensure no colormap or CData overrides:
set(hSurf, 'FaceColor', col, 'CDataMapping', 'direct');
% Do NOT call colormap(...) here (that would affect surfaces with CData)

% optional axes arrows
if opts.showAxes
    for k=1:3
        dirVec = V(:,k) * radii(k);
        quiver3(0,0,0, dirVec(1), dirVec(2), dirVec(3), 0, 'k', 'LineWidth', 1.5, 'MaxHeadSize',0.5);
    end
end

if nargout>0
    h = hSurf;
end
end
