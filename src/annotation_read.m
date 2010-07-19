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

                case 3, [database]=strread(line,matchstrs(matchnum).str);
                    % This has not been implemented yet.
                    % record.database=char(database);

                case 4, [obj,lbl,xmin,ymin,xmax,ymax]...
                        =strread(line,matchstrs(matchnum).str);
                    reg_offset = annotation.reg_offset + 1;
                    annotation.regions(reg_offset) = annotation_init;
                    annotation.regions(reg_offset).label = char(lbl);
                    annotation.regions(reg_offset).bbox = [xmin,ymin,xmax,ymax];
                    annotation.regions(reg_offset).active = 1;

                    % prepare the next element for the next iteration.
                    annotation.reg_offset = reg_offset;

                case 5, tmp=findstr(line,' : ');
                    % The polygon stuff has not been implemented.
                    % [obj,lbl]=strread(line(1:tmp),matchstrs(matchnum).str);
                    % record.objects(obj).label=char(lbl);
                    % record.objects(obj).polygon=sscanf(line(tmp+3:end),'(%d, %d) ')';

                case 6, [obj,lbl,mask]=strread(line,matchstrs(matchnum).str);
                    % I don't know what pixel mask is....
                    % record.objects(obj).label=char(lbl);
                    % record.objects(obj).mask=char(mask);

                case 7, [obj,lbl,orglbl]=strread(line,matchstrs(matchnum).str);
                    % I don't know what original label is.
                    %record.objects(obj).label=char(lbl);
                    %record.objects(obj).orglabel=char(orglbl);

                case 8, [date, reviewer]=strread(line,matchstrs(matchnum).str);
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
    s(3).str='Database : %q';

    s(4).matchlen=8;
    s(4).str='Bounding box for object %d %q (Xmin, Ymin) - (Xmax, Ymax) : (%d, %d) - (%d, %d)';

    s(5).matchlen=7;
    s(5).str='Polygon for object %d %q (X, Y)';

    s(6).matchlen=5;
    s(6).str='Pixel mask for object %d %q : %q';

    s(7).matchlen=8;
    s(7).str='Original label for object %d %q : %q';
    
    s(8).matchlen=6;
    s(8).str='Review %s %s';

return
