% --- Returns an empty annotation.  Initialized annotation.
% --- This is a helper function.
function object=annotation_init
  object.label='';
  object.orglabel='';
  object.bbox=[];       % The line coordinates
  object.bboxline.l = -1;  %linehandle
  object.bboxline.t = -1;  %texthandle
  object.polygon=[];
  object.mask='';
  
  % When this var is set it expresses the coordinates in the figure (as
  % opposed to the axis) of the box.
  object.bbox_figure =[];
  
  % This var expresses the validity of the region. 0 means inactive
  % (basically does not count.  will not save it).  1 means active.
  object.active = 0;
return