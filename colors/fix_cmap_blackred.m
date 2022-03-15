function cm = fix_cmap_blackred(n)

if nargin < 1
    n = 100;
end

c = linspace(0, 1, n)';

cm = c * fix_col_red;
