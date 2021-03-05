function h = fix_figure(h, bkg_col)
% function h = fix_figure(h, bkg_col)

if nargin < 1 || isempty(h)
    h = gcf;
end

if nargin < 2
    bkg_col = 'w';
end

set(gcf, 'color', bkg_col)