function hl = fix_plot_yeq0_line(ha, col, sty)
% function hl = fix_plot_yeq0_line(ha, col, sty)

if nargin < 1
    ha = gca;
end

if nargin < 2
    col = [0 0 0];
end

if nargin < 3
    sty = ':';
end

xl = xlim(ha);

hold on
hl = plot(ha, xl, [0 0], 'color', col, 'linestyle', sty);
