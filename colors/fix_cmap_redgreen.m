function cm = fix_cmap_redgreen(n)

if nargin < 1
    n = [100 100];
end

n1 = n(1);
n2 = n(2);

c1 = linspace(0, 1, round(n1/2))';
z1 = zeros(size(c1));

c2 = linspace(0, 1, round(n2/2))';
z2 = zeros(size(c2));


cm = [[flip(c1) z1 z1]; [z2 c2 z2]];
