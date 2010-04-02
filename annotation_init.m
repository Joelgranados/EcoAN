% --- Returns an empty annotation.  Initialized annotation.
% --- This is a helper function.
function object=annotation_init
  object.label='';
  object.orglabel='';
  object.bbox=[];
  object.polygon=[];
  object.mask='';
return