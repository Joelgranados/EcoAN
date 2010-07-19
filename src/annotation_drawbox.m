% Draws a red box over the specified points
function [l, t] = annotation_drawbox(pts, lbl, color, callback)
% pts   The points where we should draw the box.
l = line(pts([1 3 3 1 1]),pts([2 2 4 4 2]),'Color',color,'LineWidth',1);
set(l, 'ButtonDownFcn', callback);

% put the label on top of the box.
% 15 pix (when we can) so the message can be seen.
if pts(2) > 15
    t = text(pts(1), pts(2)-15, char(lbl), 'Color', color, 'FontSize', 16);
else
    t = text(pts(1), pts(2), char(lbl), 'Color', color, 'FontSize', 16);
end
