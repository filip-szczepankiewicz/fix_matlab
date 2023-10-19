function [h1, h2] = fix_plot_pointSurface(u, l, T)
% function [h1, h2] = fix_plot_pointSurface(u, l, T)
%
% u is the unit vector that points to the data point.
% l is the distance to origo
% T is the set of connection indices to construct the surface form a point cloud

u = u./sqrt(sum(u.^2, 2));

if nargin < 2 || isempty(l)
    l = sqrt(sum(u.^2, 2));
end

if nargin < 3 || isempty(T)
    T = MyCrustOpen(u);
    % https://se.mathworks.com/matlabcentral/fileexchange/63731-surface-reconstruction-from-scattered-points-cloud-open-surfaces
end

x = u(:,1).*l;
y = u(:,2).*l;
z = u(:,3).*l;

mv = max(abs([x(:); y(:); z(:)]));

h1 = trisurf(T,x,y,z,l,'FaceLighting','phong', 'facealpha', .5);

axis tight vis3d equal
axis([-1 1 -1 1 -1 1]*mv)

set(h1, 'edgecolor', 'none','Ambientstrength',0.9,'DiffuseStrength',0.3,...
    'SpecularStrength',0.5,'Specularexponent',10,'FaceLighting','Phong');

shading interp

hold on
h2 = plot3(x, y, z, 'k.', 'markersize', 2);