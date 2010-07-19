% Annotation.  An annotation creation tool for images.
% Copyright (C) 2010 Joel Granados <joel.granados@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

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

