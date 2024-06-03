function str = fix_datestr(strin, mode)

if nargin < 2
    mode = 1;
end

str = datestr(strin);
str = strrep(str, ':', '.');

switch mode
    case 0
        % do nothing

    case 1
        str = strrep(str, '.', '_');

    otherwise
        error('mode not recognized!')
end