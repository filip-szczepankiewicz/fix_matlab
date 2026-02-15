function [u, T] = fix_getSurface(mode)
% function [u, T] = fix_getSurface(mode)
%
% Loads vertices (u) and faces (T) of 3D models.

switch mode
    case {1, 'sphere100'}
        [u, T] = fix_openCrust_100();

    case {2, 'sphere250'}
        [u, T] = fix_openCrust_250();

    case {3, 'sphere500'}
        [u, T] = fix_openCrust_500();

    case {4, 'sphere1000'}
        [u, T] = fix_openCrust_1000();

    case {5, 'cardiac', 'heart'}
        load('fix_surfaceCardiac.mat', 'u', 'T');

    case {6, 'brain'}
        load('fix_surfaceBrain.mat', 'u', 'T');

    otherwise
        error('Surface not recognized!')

end