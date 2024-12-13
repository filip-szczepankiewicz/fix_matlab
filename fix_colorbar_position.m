function h = fix_colorbar_position(h, m, a)

if nargin < 1 || isempty(h)
    hl = findall(gcf,'type','ColorBar');
    h = hl(1);
end

if nargin < 2 || isempty(m)
    m = [1 1 1 1];
end

if nargin < 3 || isempty(a)
    a = [0 0 0 0];
end

pos = get(h, 'position');
set(h, 'position', (pos+[0.00001 0 0 0]).*m+a);