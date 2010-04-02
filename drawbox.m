% Draws a red box over the specified points
function drawbox(pts)
% pts   The points where we should draw the box.
    line(pts([1 3 3 1 1]),pts([2 2 4 4 2]),'Color',[1 0 0],'LineWidth',1);
end