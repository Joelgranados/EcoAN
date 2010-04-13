function ret_ann = put_annotations_in_axis (annotation)
% annotation    The annotation that contains the regions that we are going
%               to paint.

ret_ann = annotation;

% % Remember that the last region is empty.
num_reg = size(ret_ann.regions, 2);

for i = 1:num_reg
    % we paint only the active ones.
    if annotation.regions(i).active == 1
        [l, t] = drawbox(ret_ann.regions(i).bbox, ret_ann.regions(i).label);
        ret_ann.regions(i).bboxline.l = l;
        ret_ann.regions(i).bboxline.t = t;
    end
end
