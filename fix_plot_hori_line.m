function hl = fix_plot_hori_line(ha, yval, col)
% function hl = fix_plot_hori_line(ha, yval, col)

if nargin < 1
    ha = gca;
end

if nargin < 2
    yval = mean(ylim(ha));
end

if nargin < 3
    col = [];
end

xl = xlim(ha);

hp = ha.Parent;

if isempty(col)

    switch hp.Theme.BaseColorStyle
        case 'dark'
            col = [1 1 1];

        otherwise
            col = [0 0 0];
    end
end

hold on
hl = plot(ha, xl, [1 1]*yval, '--', 'Color', col);

