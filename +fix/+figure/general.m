function h = general(h, bkg_col)
% function h = general(h, bkg_col)
%
% General fixes for figure object

if nargin < 1 || isempty(h)
    h = gcf;
end

if nargin < 2
    bkg_col = 'w';
end

set(gcf, 'color', bkg_col)

fix_figure_theme