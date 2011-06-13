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


% --- Returns an empty annotation.  Initialized annotation.
% --- This is a helper function.
function object=annotation_init
  object.label='';
  object.bbox=[];       % The line coordinates
  object.bboxline.l = -1;  %linehandle
  object.bboxline.t = -1;  %texthandle

  % When this var is set it expresses the coordinates in the figure (as
  % opposed to the axis) of the box.
  object.bbox_figure =[];

  % This var expresses the validity of the region. 0 means inactive
  % (basically does not count.  will not save it).  1 means active.
  object.active = 0;
return
