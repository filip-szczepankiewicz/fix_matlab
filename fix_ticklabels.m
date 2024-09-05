function t = fix_ticklabels(ax_str, tno, prec, ax_h)
% function t = fix_ticklabels(ax_str, tno, prec, ax_h)
% By Filip Szczepankiewicz 2016-01-21
% ax_str is a simple character that defines which axis is modified
% tno is the sought number of ticks (output may be off by one) (default = 5)
% prec is the precision of the labels. Can be negative to set the precision
% of non decimal numbers. -1 rounds to tens, and -2 rounds to hundreds. If
% undefined, an appropriate precision is selected.
% ax_h is the handle to the axis that is modified (default = gca)
% If function is called with no arguments, a default format will be used
% for the x and y-axes.

if nargin < 1
    fix_ticklabels('x');
    fix_ticklabels('y');
    try
        fix_ticklabels('z');
    end
    return
end

curr_ax  = [ax_str 'Tick'];
curr_lab = [ax_str 'TickLabel'];
curr_lim = [ax_str 'Lim'];

if nargin < 4 || isempty(ax_h)
    ax_h = gca;
end


if nargin < 2 || isempty(tno)
    tno = numel(get(ax_h, curr_ax));
end


if nargin < 3 || isempty(prec)

    t_labs = get(ax_h, curr_lab);
    t = cellfun(@str2num,t_labs);

    prec = 0;

    for i = 1:size(t_labs,1)

        tmp_str = t_labs{i,:};

        p_ind = strfind(tmp_str, '.');

        if ~isempty(p_ind)

            tmp_prec = length(tmp_str) - p_ind;

            if tmp_prec > prec
                prec = tmp_prec;
            end

        end

    end


else

    if prec ~= round(prec); error('Precision must be an integer!'); end

    tlims = get(ax_h, curr_lim);

    d = round(range(tlims)/tno*10^prec)/10^prec;

    if d == 0; d = ceil(range(tlims)/tno*10^prec)/10^prec; end

    tstart = round(min(tlims)*10^prec)/10^prec;

    t = (tstart:d:max(tlims))';

end

set(ax_h, curr_ax, t,curr_lab, cellstr( num2str(t, [' %01.' num2str(max([0 prec])) 'f']) )  )




















