function hl = fix_legend(hl, fs, ts)
% function hl = fix_legend(hl, fs, ts)
% Filip Szczepankiewicz

if nargin < 1 || isempty(hl)
    hl = findobj(gcf, 'Type', 'Legend');
end

if nargin < 2 || isempty(fs)
    fs = 6;
end

if nargin < 3 || isempty(ts)
    ts = 10;
end


for i = 1:numel(hl)
    set(hl(i), 'box', 'off', 'FontSize', fs)
    hl(i).ItemTokenSize = [1 1]*ts;
end