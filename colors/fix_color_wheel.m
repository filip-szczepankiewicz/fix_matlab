function [I, R, A, h] = fix_color_wheel(s, do_plot, c_mat)
% function [I, R, A, h] = fix_color_wheel(s, do_plot, c_mat)


if nargin < 1
    s = 1001;
end

if nargin < 2
    do_plot = 1;
end

if nargin < 3
    c_mat = hsv;
end


c = round(s/2);

x = linspace(-c, c, s);
y = linspace(-c, c, s);

I = ones(s);
R = ones(s);

for i = 1:s
    
    ang =  y / x(i);
    
    I(i,:) = atand(ang);
    
    r = sqrt(y.^2 + x(i)^2);
    
    R(i,:) = r/c;
    
    I(i,r>c) = nan;
end

A = (R<1) .* R;

if do_plot
    set(gcf, 'color', 'w')
    h = imagesc(I);
    colormap(c_mat)
    hold on
    set(h, 'alphadata', A)
    caxis([-90 90])
    axis image off
end




