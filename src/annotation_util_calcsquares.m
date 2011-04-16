function [fixed_figure, fixed_axis] = annotation_util_calcsquares (bbt, bbox_figure, p1)
    % xdiff is center_x - current_x
    xdiff = (bbt(1)+(abs(bbt(3)-bbt(1))/2)) - (p1(1,1));
    % ydiff is center_y - current_y
    ydiff = (bbt(2)+(abs(bbt(4)-bbt(2)))/2) - (p1(1,2));

    if xdiff < 0 && ydiff > 0
        %fixed in lower left
        fixed_figure = [ bbox_figure(1), bbox_figure(2) ];
        fixed_axis = [ bbt(1), bbt(4) ];
    elseif xdiff >= 0 && ydiff >= 0
        %fixed in lower right
        fixed_figure = [ bbox_figure(1)+bbox_figure(3),...
            bbox_figure(2) ];
        fixed_axis = [ bbt(3), bbt(4) ];
    elseif xdiff > 0 && ydiff < 0
        %fixed in upper right
        fixed_figure = [ bbox_figure(1)+bbox_figure(3),...
            bbox_figure(2)+bbox_figure(4) ];
        fixed_axis = [bbt(3), bbt(2) ];
    elseif xdiff <= 0 && ydiff <= 0
        %fixed in upper left
        fixed_figure = [ bbox_figure(1),...
            bbox_figure(2)+bbox_figure(4) ];
        fixed_axis = [ bbt(1), bbt(2) ];
    end