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


function annotation_save(handles, annotation)
    annotation_save_VER20(handles, annotation);
end

function annotation_save_VER20(handles, annotation)
    verstr = strcat(int2str(2),'.',int2str(0));
    ann_file_name = char(strcat(annotation.file_name, '.csv'));

    [fd,syserrmsg]=fopen(ann_file_name,'wt');
    if (fd==-1),
        msgboxText{1} =  strcat('Error saving to file: ', ann_file_name);
        msgbox(msgboxText,'Please try to save again.');
        return;
    end;

    [p,f,e] = fileparts(char(annotation.file_name));
    file_name = strcat(f,e);

    fprintf(fd, '#PHENOLOGY ITU Annotation Version %s\n', verstr);
    fprintf(fd, '#CVS format (1,2,3,4,5,6 are reserved for future use):\n');
    fprintf(fd, '#Xmin,Ymin,Width,Height describe the containing square\n');
    fprintf(fd, '#fileName,FormatVersion,LabelName,lastReviewer,');
    fprintf(fd, 'reviewData,Xmin,Ymin,Width,Height,1,2,3,4,5,6,');
    fprintf(fd, 'X1,Y1,X2,Y2...,XN,YN\n');

    % The last region is always empty.
    for i=1:annotation.reg_offset,
        % We only save the active regions.
        if annotation.regions(i).active == 1
            lbl = char(get(annotation.regions(i).label, 'string'));

            % Create [Xmin, Ymin, Width, Heigth] and [X1,Y1....XN,YN]
            if isa(annotation.regions(i).roi, 'imrect')
                square = round(getPosition(annotation.regions(i).roi));
                vertices = [square(1) square(2);...
                    square(1) square(2)+square(4);...
                    square(1)+square(3) square(2)+square(4);...
                    square(1)+square(3) square(2)];

            elseif isa(annotation.regions(i).roi, 'impoly') ||...
                    isa(annotation.regions(i).roi, 'imfreehand')
                vertices = round(getPosition(annotation.regions(i).roi));
                xmin = min(vertices(:,1));
                ymin = min(vertices(:,2));
                xmax = max(vertices(:,1));
                ymax = max(vertices(:,2));
                square = [xmin, ymin, xmax-xmin, ymax-ymin];

            else
                % ERROR!!!
                msgboxText{1} = strcat('Error: Unkown roi type to save');
                msgbox(msgboxText,'Please try to save again.');
                return;
            end;

            fprintf(fd, '%s,%s,%s,%s,%s,,,,,,',...
                char(file_name),verstr,lbl,...
                char(annotation.review.reviewer),...
                char(annotation.review.date) );
            fprintf(fd, ',%d,%d,%d,%d', square);
            for j=1:size(vertices,1),
                fprintf(fd, ',%d,%d', vertices(j,1), vertices(j,2));
            end
            fprintf(fd, '\n');
        end
    end
    fclose(fd);
end

function annotation_save_VER10(handles, annotation)
    % WE SAVE ANNOTATION LOCALY
    VERSION=1.0;
    ann_file_name = char(strcat(annotation.file_name, '.ann'));

    [fd,syserrmsg]=fopen(ann_file_name,'wt');
    if (fd==-1),
        msgboxText{1} =  strcat('Error saving to file: ', ann_file_name);
        msgbox(msgboxText,'Please try to save again.');
        return;
    end;

    [p,f,e] = fileparts(char(annotation.file_name));
    file_name = strcat(f,e);

    fprintf(fd,'# PHENOLOGY ITU Annotation Version %0.2f\n',VERSION);
    fprintf(fd,'\n');
    fprintf(fd,'Image filename : "%s"\n',char(file_name));
    fprintf(fd,'\n');
    fprintf(fd,'# Top left pixel co-ordinates : (1, 1)\n');
    fprintf(fd,'\n');
    fprintf(fd,'Review %s %s', char(annotation.review.date),...
        char(annotation.review.reviewer));

    % The last region is always empty.
    size_regions = size(annotation.regions, 2);
    for i=1:size_regions,
        % We only save the active regions.
        if annotation.regions(i).active == 1
            bbox = round(getPosition(annotation.regions(i).roi));
            bbox = [bbox(1), bbox(2), bbox(1)+bbox(3), bbox(2)+bbox(4)];
            lbl = char(get(annotation.regions(i).label, 'string'));
            fprintf(fd,'\n# Details for object %d ("%s")\n',i,lbl);
            fprintf(fd,'Bounding box for object %d "%s" ', i, lbl);
            fprintf(fd, '(Xmin, Ymin) - (Xmax, Ymax) : ');
            fprintf(fd, '(%d, %d) - (%d, %d)\n',bbox);

        end
    end;

    fclose(fd);
end
