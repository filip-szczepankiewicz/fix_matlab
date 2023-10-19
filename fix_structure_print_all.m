function hp = fix_structure_print_all(h, prefix)
% function hp = fix_structure_print_all(h, prefix)

if nargin < 2
    prefix = '';
end

fn = fieldnames(h);

for i = 1:numel(fn)

    hp = h.(fn{i});

    if isstruct(hp)
        fix_structure_print_all(hp, [prefix '.' fn{i}]);
    else
        if isnumeric(hp)
            disp([prefix fn{i} ' = ' num2str(hp(:)')])
        else
            try
                disp([prefix fn{i} ' = ' hp(:)'])
            catch
                warning([prefix fn{i} ' = UNKNOWN'])
            end
        end
    end
end