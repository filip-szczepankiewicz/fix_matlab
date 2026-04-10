function cm = blackred(n)
% function cm = blackred(n)

if nargin < 1
    n = 100;
end

c = linspace(0, 1, n)';

cm = c * fix.color.red;
