function hl = line1to1(ha, col)
% function hl = line1to1(ha, col)

warning('Deprecated: Replace by plot(xlim, ylim, ...)')

if nargin < 1
    ha = gca;
end

if nargin < 2
    col = [];
end

xl = xlim(ha);
yl = ylim(ha);

lo = min([xl(1) yl(1)]);
hi = min([xl(2) yl(2)]);

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
hl = plot(ha, [lo hi], [lo hi], '--', 'Color', col);

