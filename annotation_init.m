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
return