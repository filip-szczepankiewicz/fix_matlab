function cm = fix_cmap_blackredwhite(n)

if nargin < 1
    n = 100;
end

c = linspace(0, 1, round(n/2))';

cm = [c * fix_col_red; fix_col_red+c*(1-fix_col_red)];
