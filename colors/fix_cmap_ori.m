function cm = fix_cmap_ori_bluered(n, c1, c2)

if nargin < 1
    n = 200;
end

if nargin < 2
    c1 = [.8 .1 .1];
end

if nargin < 3
    c2 = [.1 .8 .1];
end

c = linspace(0, 1, round(n/2))';

cm = c*c1 + flip(c)*c2;

cm = [cm; flip(cm)];
