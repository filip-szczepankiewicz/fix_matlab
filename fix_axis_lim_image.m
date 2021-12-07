function lims = fix_axis_lim_image(hax, pad)

if nargin < 1
    hax = gca;
end

if nargin < 2
    pad = 1;
end

I = getimage(hax);

I = sum(I,3);

Ix = sum(abs(I),1);
Iy = sum(abs(I),2);

x1 = find(Ix, 1, 'first');
x2 = find(Ix, 1, 'last');

y1 = find(Iy, 1, 'first');
y2 = find(Iy, 1, 'last');

lims = [x1 x2 y1 y2]+[-1 1 -1 1]*pad;

axis(hax, lims)