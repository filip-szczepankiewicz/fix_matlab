function h = fix_colorbar_position(h, m, a)

if nargin < 2
    m = [1 1 1 1];
end

if nargin < 3
    a = [0 0 0 0];
end

pos = get(h, 'position');
set(h, 'position', (pos+[0.00001 0 0 0]).*m+a);