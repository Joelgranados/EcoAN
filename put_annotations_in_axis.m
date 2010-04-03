function put_annotations_in_axis (annotation)
% annotation    The annotation that contains the regions that we are going
%               to paint.

% First get the regions
regions = annotation.regions;

% Remember that the last region is empty.
num_reg = size(regions, 2) - 1;

for i = 1:num_reg
    drawbox(regions(i).bbox, regions(i).label);
end