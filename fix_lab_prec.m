function fix_lab_prec(h, axs, format)

if nargin < 1 || isempty(h)
    h = gca;
end

if nargin < 2 || isempty(axs)
    axs = 'xy';
end

if nargin < 3 || isempty(format)
    format = '%0.1f';
end

if isnumeric(format)
    format = ['%0.' num2str(round(format)) 'f'];
end

for i = 1:numel(axs)
    lbtick = [axs(i) 'Tick'];
    lblstr = [axs(i) 'TickLabel'];
    lbstrs = get(gca, lblstr);
    nums = cellfun(@str2num, lbstrs);
    if ~isempty(lbstrs)
        set(h, lbtick, nums, lblstr, num2str(nums, format) )
    end
end