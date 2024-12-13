function [par, hax] = fix_subplot(par, i)
% function [par, hax] = fix_subplot(par, i)
% By Filip Szczepankiewicz
% i   = plot index from left to right
% par = structure with formatting parameters

if nargin == 1 && strcmp(par, 'tight')
    clear par
    par.order = 'byRow';
    par.lo = 0; % Left offset
    par.ro = 0; % Right offset

    par.bo = 0; % Bottom offset
    par.to = 0; % Top offset

    par.ho = 0; % Height offset (between subplots top-bottom direction)
    par.wo = 0; % Width offset (Between subplots left-right direction)

    par.nc = 2; % Number of collumns
    par.nr = 2; % Number of rows

    par.hax = nan;

    return;
end


if nargin < 1
    par.order = 'byRow';
    par.lo = 0.05; % Left offset
    par.ro = 0.05; % Right offset

    par.bo = 0.05; % Bottom offset
    par.to = 0.05; % Top offset

    par.ho = 0.05; % Height offset (between subplots top-bottom direction)
    par.wo = 0.05; % Width offset (Between subplots left-right direction)

    par.nc = 2;
    par.nr = 2;

    par.hax = nan;

    return;

else
    order = par.order;
    lo = par.lo;
    ro = par.ro;

    bo = par.bo;
    to = par.to;

    ho = par.ho;
    wo = par.wo;

    nc = par.nc;
    nr = par.nr;
end

if isfield(par, 'w')
    w = par.w;
else
    w = (1-lo-ro-(nc-1)*wo)/nc;
end

if isfield(par, 'h')
    h = par.h;
else
    h = (1-to-bo-(nr-1)*ho)/nr;
end

if nargin > 1
    switch order
        case {'byRow', 1}
            r = ceil(i/nc);
            c = i - (r-1)*nc;

        case {'byCol', 2}
            c = ceil(i/nr);
            r = i - (c-1)*nr;

    end
end

hax = axes('position', [(lo+(c-1)*(w+wo)) (1-(to+r*h+(r-1)*ho)) w h]);

par.hax = hax;
par.r = r;
par.c = c;
par.w = w;
par.h = h;


