function c = fix_cmap_redgray(n1, n2)

if nargin < 1
    clim = get(gca, 'clim');
    
    if clim(1)<0
        n1 = round(abs(clim(1)/range(clim) * 200));
    else
        n1 = 0;
    end
    
    if clim(2)>0
        n2 = round(abs(clim(2)/range(clim) * 200));
    else
        n2 = 0;
    end
end

d = linspace(1, 0, n1);

a = linspace(0, 1, n2);

c = [d'*fix_col_red; a'*[1 1 1]];
