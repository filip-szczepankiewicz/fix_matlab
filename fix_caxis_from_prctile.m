function bounds = fix_caxis_from_prctile(h, prct)
% function bounds = fix_caxis_from_prctile(h, prct)

if nargin < 1 || isempty(h)
    h = gca;
end

if nargin < 2
    prct = [.1 99.9];
end

d = getimage;

bounds = prctile(d(:), prct);

if bounds(1)==bounds(2)
    bounds(2)=bounds(2)+0.1;
end

caxis(h, bounds)

