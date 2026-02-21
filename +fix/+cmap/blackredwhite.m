function cm = blackredwhite(n)
% function cm = blackredwhite(n)

if nargin < 1
    n = 100;
end

c = linspace(0, 1, round(n/2))';

cm = [c * fix.color.red; fix.color.red+c*(1-fix.color.red)];
