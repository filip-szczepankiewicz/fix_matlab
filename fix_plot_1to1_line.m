function hl = fix_plot_1to1_line(ha)
% function hl = fix_plot_1to1_line(ha)

if nargin < 1
    ha = gca;
end

xl = xlim(ha);
yl = ylim(ha);

lo = min([xl(1) yl(1)]);
hi = min([xl(2) yl(2)]);

hold on
hl = plot(ha, [lo hi], [lo hi], 'k--');

