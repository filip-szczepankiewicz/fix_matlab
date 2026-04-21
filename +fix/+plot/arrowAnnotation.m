function h = arrowAnnotation(ax, direction, pos1, pos2, fixed, varargin)
% function h = fix.plot.arrowAnnotation(ax, direction, pos1, pos2, fixed, varargin)
% By Filip Sz and Claude.AI
%
% Add a labeled horizontal or vertical arrow to a plot.
%
% USAGE
%   h = plot_arrow(ax, 'h', x1, x2, y)          % horizontal arrow
%   h = plot_arrow(ax, 'v', y1, y2, x)          % vertical arrow
%   h = plot_arrow(__, Name, Value, ...)
%
% REQUIRED INPUTS
%   ax          - target axes handle (use gca if needed)
%   direction   - 'h' (horizontal) or 'v' (vertical)
%   pos1, pos2  - start and end along the arrow axis (x for 'h', y for 'v')
%   fixed       - position on the perpendicular axis (y for 'h', x for 'v')
%
% OPTIONS (Name-Value pairs)
%   'Text'          - string label at arrow midpoint          (default: '')
%   'TextSide'      - 'above'|'below' (horiz.) or 'left'|'right' (vert.)
%                     (default: 'above' / 'right')
%   'TextOffset'    - perpendicular clearance between arrow and text in axis
%                     units. With correct anchor alignment the text already
%                     sits flush, so this is just a small breathing gap.
%                     (default: 0.5% of perpendicular axis span)
%   'TextPosition'  - [dx dy] additive offset applied to the text position
%                     in axis units, for fine-tuning placement after the
%                     automatic positioning.                    (default: [0 0])
%   'Leaders'       - [p1, p2] positions from which leader lines are drawn
%                     to the arrow. For 'h', these are x-values at a given
%                     LeaderFrom y; for 'v' they are y-values at a given
%                     LeaderFrom x. Set to [] to disable.          (default: [])
%   'LeaderFrom'    - perpendicular position(s) where leaders originate.
%                     Scalar: both leaders start at the same depth.
%                     1x2 vector: [from1, from2] lets each leader start at
%                     a different depth (useful when the two reference points
%                     lie at different perpendicular positions).
%                     (default: same side as text, offset further)
%   'ArrowStyle'    - 'double' (both ends) | 'forward' | 'back' 
%   'Color'         - line/arrow/text color      
%   'LineWidth'     - line width                   
%   'FontSize'      - text font size                 
%   'FontName'      - font name for label text 
%   'HeadSize'      - arrowhead size in points   
%   'LeaderStyle'   - line style for leader lines
%
% OUTPUT
%   h  - struct with handles: h.arrow, h.text, h.leaders
%
% EXAMPLE (horizontal, with leaders at different depths)
%   figure; plot(1:10, rand(1,10), 'k'); ax = gca;
%   plot_arrow(ax, 'h', 2, 7, 0.8, 'Text', '5 units', ...
%       'TextSide', 'above', 'FontName', 'Times New Roman', ...
%       'Leaders', [2 7], 'LeaderFrom', [0.3 0.6]);
%
% EXAMPLE (vertical, no leaders)
%   figure; plot(rand(1,10), 1:10, 'k'); ax = gca;
%   plot_arrow(ax, 'v', 3, 8, 0.2, 'Text', '\Deltay', ...
%       'TextSide', 'left', 'FontName', 'Helvetica');

% --- Parse inputs ---------------------------------------------------------
p = inputParser;
p.addParameter('Text',        '',        @ischar);
p.addParameter('TextSide',    'auto',    @ischar);
p.addParameter('TextOffset',  [],        @(x) isempty(x) || isnumeric(x));
p.addParameter('TextPosition',[0 0],     @(x) isnumeric(x) && numel(x)==2);
p.addParameter('Leaders',     [],        @isnumeric);
p.addParameter('LeaderFrom',  [],        @(x) isempty(x) || (isnumeric(x) && numel(x) <= 2));
p.addParameter('ArrowStyle',  'double',  @ischar);
p.addParameter('Color',       [0 0 0],   @(x) isnumeric(x) || ischar(x));
p.addParameter('LineWidth',   0.5,       @isnumeric);
p.addParameter('FontSize',    8,         @isnumeric);
p.addParameter('FontName',    'Times',   @ischar);
p.addParameter('HeadSize',    1.5,       @isnumeric);
p.addParameter('LeaderStyle', ':',       @ischar);
p.parse(varargin{:});
opt = p.Results;

direction = lower(direction(1));
assert(ismember(direction, {'h','v'}), 'direction must be ''h'' or ''v''.');

% Resolve default TextSide
if strcmp(opt.TextSide, 'auto')
    if direction == 'h', opt.TextSide = 'above'; else, opt.TextSide = 'right'; end
end

% Make sure axes are up to date (needed for axis-unit calculations)
hold(ax, 'on');

% --- Axis-unit-based auto offset ------------------------------------------
% TextOffset is a small perpendicular clearance between arrow and text.
% With correct valign/halign anchoring the text already sits flush against
% the arrow, so the default only needs to provide a small breathing gap.
axlim_perp = get_perp_lim(ax, direction);  % limits on the perpendicular axis
span_perp   = diff(axlim_perp);
auto_offset = span_perp * 0.005;           % ~0.5% of axis span — just a gap

if isempty(opt.TextOffset)
    opt.TextOffset = auto_offset;
end

% --- Draw arrow(s) --------------------------------------------------------
mid = (pos1 + pos2) / 2;

% Annotation arrows require normalised figure coordinates; we use the
% annotation() function with 'arrow' and handle both ends manually.
% It is more robust to use annotation arrows converted from data coords.

h.arrow  = [];
h.text   = [];
h.leaders = [];

switch opt.ArrowStyle
    case 'double'
        h.arrow(1) = draw_annotation_arrow(ax, direction, pos1, pos2, fixed, opt);
        h.arrow(2) = draw_annotation_arrow(ax, direction, pos2, pos1, fixed, opt);
    case 'forward'
        h.arrow    = draw_annotation_arrow(ax, direction, pos1, pos2, fixed, opt);
    case 'back'
        h.arrow    = draw_annotation_arrow(ax, direction, pos2, pos1, fixed, opt);
    otherwise
        error('ArrowStyle must be ''double'', ''forward'', or ''back''.');
end

% --- Text label -----------------------------------------------------------
if ~isempty(opt.Text)
    % Perpendicular offset direction
    sign_offset = text_sign(direction, opt.TextSide);
    text_perp   = fixed + sign_offset * opt.TextOffset;

    if direction == 'h'
        tx = mid  + opt.TextPosition(1);
        ty = text_perp + opt.TextPosition(2);
        halign = 'center';
        % ty is already offset away from the arrow, so anchor the text
        % on the side facing the arrow (bottom when above, top when below)
        valign = pick(opt.TextSide, 'above', 'bottom', 'top');
    else
        tx = text_perp + opt.TextPosition(1);
        ty = mid  + opt.TextPosition(2);
        % Anchor on the side facing the arrow:
        % TextSide='right' → tx is right of arrow → halign='left'  (text extends further right)
        % TextSide='left'  → tx is left of arrow  → halign='right' (text ends at tx, flush to arrow)
        halign = pick(opt.TextSide, 'right', 'left', 'right');
        valign = 'middle';
    end

    h.text = text(ax, tx, ty, opt.Text, ...
        'HorizontalAlignment', halign, ...
        'VerticalAlignment',   valign, ...
        'FontSize',            opt.FontSize, ...
        'FontName',            opt.FontName, ...
        'Color',               opt.Color);
end

% --- Leader lines ---------------------------------------------------------
if ~isempty(opt.Leaders)
    assert(numel(opt.Leaders) == 2, '''Leaders'' must have exactly 2 elements.');

    % Default LeaderFrom: same perpendicular side as text, further out
    if isempty(opt.LeaderFrom)
        sign_offset = text_sign(direction, opt.TextSide);
        opt.LeaderFrom = fixed + sign_offset * opt.TextOffset * 3;
    end

    % Expand scalar LeaderFrom to per-leader vector
    if isscalar(opt.LeaderFrom)
        leader_from = [opt.LeaderFrom, opt.LeaderFrom];
    else
        leader_from = opt.LeaderFrom(:)';   % ensure 1x2
    end

    for k = 1:2
        if direction == 'h'
            lx = [opt.Leaders(k), opt.Leaders(k)];
            ly = [leader_from(k), fixed];
        else
            lx = [leader_from(k), fixed];
            ly = [opt.Leaders(k), opt.Leaders(k)];
        end
        h.leaders(k) = plot(ax, lx, ly, ...
            opt.LeaderStyle, ...
            'Color',     [opt.Color 0.3], ...
            'LineWidth', opt.LineWidth);
    end
end

end % main function

% =========================================================================
% HELPERS
% =========================================================================

function ha = draw_annotation_arrow(ax, direction, from_pos, to_pos, fixed, opt)
% Draws a single arrowhead from from_pos toward to_pos along the arrow axis,
% with the shaft connecting the two endpoints.

% Convert data coordinates -> normalised figure coordinates
if direction == 'h'
    x_data = [from_pos, to_pos];
    y_data = [fixed,    fixed];
else
    x_data = [fixed,    fixed];
    y_data = [from_pos, to_pos];
end

[xn, yn] = data2norm(ax, x_data, y_data);

ha = annotation('arrow', xn, yn, ...
    'Color',     opt.Color, ...
    'LineWidth', opt.LineWidth, ...
    'HeadWidth', opt.HeadSize * 1.5, ...
    'HeadLength',opt.HeadSize);
end

% -------------------------------------------------------------------------
function [xn, yn] = data2norm(ax, xd, yd)
% Convert data-space coordinates to normalised figure coordinates.
fig = ancestor(ax, 'figure');
ax_pos  = get(ax,  'Position');       % axes in normalised fig units
fig_pos = get(fig, 'Position');       % fig in pixels (unused here)

xl = xlim(ax);  yl = ylim(ax);

% Normalise within axes, then map to figure
xn = ax_pos(1) + ax_pos(3) * (xd - xl(1)) / diff(xl);
yn = ax_pos(2) + ax_pos(4) * (yd - yl(1)) / diff(yl);
end

% -------------------------------------------------------------------------
function lim = get_perp_lim(ax, direction)
if direction == 'h', lim = ylim(ax); else, lim = xlim(ax); end
end

% -------------------------------------------------------------------------
function s = text_sign(direction, side)
% Returns +1 or -1 for the text offset direction.
if direction == 'h'
    s = 2 * strcmp(side, 'above') - 1;   % above -> +1, below -> -1
else
    s = 2 * strcmp(side, 'right') - 1;   % right -> +1, left  -> -1
end
end

% -------------------------------------------------------------------------
function out = pick(val, match, yes, no)
% Ternary: if val==match return yes, else no.
if strcmp(val, match), out = yes; else, out = no; end
end