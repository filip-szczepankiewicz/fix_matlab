function fn = fix_save_figure (out_name, out_dir, imsize, res, out_format)
% function fn = fix_save_figure (out_name, out_dir, imsize, res, out_format)
% By: Filip Szczepankiewicz, 2014.09.24
% This function saves the current graphic in a customizable format!
% out_name      Output name of file, without file ending!
% out_dir       The path to the directory where the image is saved. If this
%               is undefined, set to '', or left empty the default is PWD.
% imsize        The absolute size [x y] of the image in inches.
% res           The resolution of the image in dots per inch (DPI). Second
%               element defines resampling of the image. res(2) < 1 shrinks, > 1
%               enlarges.
% out_format    The format of the saved image. See code for available
%               formats.


do_fix_axes = 0; % Fixes issues where axes dissapear in old matlab versions
do_disable_col_invert = 1;
do_force_w_bkg = 0;


if (nargin < 2 || strcmp(out_dir, '') || isempty(out_dir))
    global dir_desktop
    out_dir = dir_desktop;
end

if (nargin < 3)
    % Keep current size of the figure window
else
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', [1 1 imsize]);
end

if (nargin < 4)
    res = [600 1];
end

if (numel(res) == 1)
    res = [res 1];
end

if (nargin < 5)
    out_format = 'png';
    
    % Other compatible formats:
    % png, pdf, jpeg, epsc, bmp
end


% Check for crazy values (may be removed)
if res(1) > 3000
    error('Resolution is likely too high!')
end

if (res(1)*res(2)) > 2000
    error('Resolution is likely too high!')
end


% Fix missing file separator
if ~strcmp(out_dir(end), filesep)
    out_dir = [out_dir filesep];
end


% Fix missing axis
if do_fix_axes
    f = get(gcf);
    for i = 1:numel(f.Children)
        tmp = get(f.Children(i));
        try
            ct = tmp.CameraTarget * (1 + 0.0000001);
            set(f.Children(i), 'CameraTarget', ct)
        catch
            disp('Camera could not be adjusted!')
        end
    end
end

% Enables changed background colors when printing
if do_disable_col_invert
    set(gcf, 'InvertHardCopy', 'off');
end

% Print to file
tmp_nam = [out_dir out_name];
fn = tmp_nam;

% Here I take care of different matlab versions handling of figure handles.
switch version
    case '8.2.0.701 (R2013b)'
        f_num = gcf;
        
    otherwise
        fig = gcf;
        f_num = fig.Number;
end



print(['-d' out_format], ['-f' num2str(f_num)], ['-r' num2str(res(1))], tmp_nam);



% Stupid, but functional, way to resample the image.
if (res(2) ~= 1)
    
    if strcmp(out_format, 'tiff')
        % This fixes a weird behaviour where matlab saves tiff as ".tif".
        i_ext = 'tif';
    else
        i_ext = out_format;
    end
    
    i_fn = [tmp_nam '.' i_ext];
    fn = i_fn;
    
    I = imread(i_fn);
    
    nfo_i = dir(i_fn);
    
    I = imresize(I, res(2), 'bicubic');
    
    try
        imwrite(I, i_fn);
    catch
        pause(0.2)
        imwrite(I, i_fn);
    end
    
    nfo_o = dir(i_fn);
    
    if res(2) < 1
        
        % Check if a reduction in size has increased the file size (happens
        % some times!!)
        
        if nfo_o.bytes > nfo_i.bytes
            warning(['Rescaled image is larger than original even if magnification < 1 !!!' ...
                'Original size = ' num2str(nfo_i.bytes) ' New size = ' num2str(nfo_o.bytes) ])
        end
    end
    
end
























