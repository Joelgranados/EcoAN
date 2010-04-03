% Draws a red box over the specified points
function drawbox(pts, lbl)
% pts   The points where we should draw the box.
line(pts([1 3 3 1 1]),pts([2 2 4 4 2]),'Color',[1 0 0],'LineWidth',1);

% put the label on top of the box.
% 15 pix (when we can) so the message can be seen.
if pts(2) > 15
    text(pts(1), pts(2)-15, char(lbl), 'Color', [1 0 0]);
else
    text(pts(1), pts(2), char(lbl), 'Color', [1 0 0]);
end