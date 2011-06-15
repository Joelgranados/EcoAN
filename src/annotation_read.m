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


% --- Reads or creats an annotation.  WILL NOT CHANGE the filesystem.
function annotation=annotation_read(file_name)
    % file_name   is the name from the original image.  We will look for the
    % text file of that image.
    ann_file_name = char(strcat(file_name, '.ann'));

    % We initialize the annotation.  Remeber that the regions vector will
    % always have an empty region at the end.
    annotation.file_name = file_name;
    annotation.reg_offset = 0;
    annotation.regions(1) = annotation_init;
    annotation.review.reviewer = 'No_Reviewer';
    annotation.review.date = 'No_Review_Date';

    % If there is no file we return an empty annotation without saving
    % The user can save with the save button and we will probably save
    % automatically when we change image.
    if exist (ann_file_name) == 0, return; end

    % We try to read the file.
    [fd,syserrmsg]=fopen(ann_file_name,'rt');
    if (fd==-1),
        msgboxText{1} =  strcat('Error reading file: ', ann_file_name);
        msgbox(msgboxText,'Please try to save again.');
    end;

    % parse the file.
    matchstrs=initstrings;
    %record=PASemptyrecord;
    EOF = 0;
    while (~EOF),
        line=fgetl(fd);
        EOF=~ischar(line);
        if (~EOF),
            matchnum=match(line,matchstrs);
            switch matchnum,
                case 1, [imgname]=strread(line,matchstrs(matchnum).str);
                    % We already know the image name, but its a good idea to check
                    % and see if the one in the file and the one we have actually
                    % coinside.
                    [p,f1,e1] = fileparts(char(file_name));
                    [p,f2,e2] = fileparts(char(imgname));
                    if strcmp(char(f1), char(f2)) == 0
                        % We have a problem.
                        % FIXME: probably be a good idea to erase this file and
                        % start a new one.  Lets error out for now.
                        msgboxText{1} =...
                            strcat('There was a format error in file ', file_name);
                        msgbox(msgboxText);
                        break;
                    end

                case 2, [x,y,c]=strread(line,matchstrs(matchnum).str);
                    %  This has not been implemented yet.
                    % record.imgsize=[x y c];

                case 3, [obj,lbl,xmin,ymin,xmax,ymax]...
                        =strread(line,matchstrs(matchnum).str);
                    reg_offset = annotation.reg_offset + 1;
                    annotation.regions(reg_offset) = annotation_init;
                    annotation.regions(reg_offset).label = char(lbl);
                    annotation.regions(reg_offset).bbox =...
                        [xmin,ymin,xmax-xmin,ymax-ymin];
                    annotation.regions(reg_offset).active = 1;

                    % prepare the next element for the next iteration.
                    annotation.reg_offset = reg_offset;

                case 4, [date, reviewer]=strread(line,matchstrs(matchnum).str);
                    annotation.review.reviewer = char(reviewer);
                    annotation.review.date = char(date);

                otherwise, %fprintf('Skipping: %s\n',line);
            end;
        end;
    end;
    fclose(fd);
return

function matchnum=match(line,matchstrs)
    for i=1:length(matchstrs),
        matched(i)=strncmp(line,matchstrs(i).str,matchstrs(i).matchlen);
    end;
    matchnum=find(matched);
    if isempty(matchnum), matchnum=0; end;
    if (length(matchnum)~=1),
        % FIXME: we should actually erase the file and create a new one
        % without any annotations.
        msgboxText{1} = 'Multiple matches while parsing.';
        msgbox(msgboxText);
    end;
return

function s=initstrings
    s(1).matchlen=14;
    s(1).str='Image filename : %q';

    s(2).matchlen=10;
    s(2).str='Image size (X x Y x C) : %d x %d x %d';

    s(3).matchlen=8;
    s(3).str='Bounding box for object %d %q (Xmin, Ymin) - (Xmax, Ymax) : (%d, %d) - (%d, %d)';

    s(4).matchlen=6;
    s(4).str='Review %s %s';

return
