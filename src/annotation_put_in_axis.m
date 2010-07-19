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


function ret_ann = annotation_put_in_axis (annotation, callback)
% annotation    The annotation that contains the regions that we are going
%               to paint.

ret_ann = annotation;

% % Remember that the last region is empty.
num_reg = size(ret_ann.regions, 2);

for i = 1:num_reg
    % we paint only the active ones.
    if annotation.regions(i).active == 1
        [l, t] = annotation_drawbox(ret_ann.regions(i).bbox,...
            ret_ann.regions(i).label, [1 0 0], callback);
        ret_ann.regions(i).bboxline.l = l;
        ret_ann.regions(i).bboxline.t = t;
    end
end
