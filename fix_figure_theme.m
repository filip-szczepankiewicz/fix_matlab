function h = fix_figure_theme(h, mode)
% function h = fix_figure_theme(h, mode)

if nargin < 1 || isempty(h)
    h = gcf;
end

if nargin < 2
    mode = 1;
end

switch mode
    case 0
        mode = 'dark';

    case 1
        mode = 'light';

    otherwise
        error('mode is not recognized!')

end

for i = 1:numel(h)

    try
        h(i).Theme = mode;

    catch me
        disp(me.message)

    end

end