function cm = fix_cmap_ori_bluered(n)

if nargin < 1
    n = 200;
end

c = linspace(0, 1, round(n/2))' .^ 0.5;
z = c*0;

cm = [

[c, flip(c), z]
[flip(c), c, z]

];

