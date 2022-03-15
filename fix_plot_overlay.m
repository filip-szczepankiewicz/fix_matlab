function h = fix_plot_overlay(Ib, If, alpha, af)
% function h = fix_plot_overlay(Ib, If, alpha, af)

if nargin < 3
    alpha = ones(size(If, [1 2]))*0.5;
end

if nargin < 4
    af = [0 0 1 1];
end


hb = axes('position', [0 0 1 1]);
imagesc(Ib)
axis image off
set(hb, 'DataAspectRatio', [1 1 1])


hf = axes ('position', af);
hi = imagesc(If);
axis image off
set(gcf, 'color', 'none')
set(gca, 'color', 'none')
set(hi, 'AlphaData', alpha)
set(hf, 'DataAspectRatio', [1 1 1])


h = {hb, hf, hi};