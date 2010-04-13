function save_annotation(annotation)
    VERSION=1.0;
    ann_file_name = char(strcat(annotation.file_name, '.txt'));

    [fd,syserrmsg]=fopen(ann_file_name,'wt');
    if (fd==-1),
        msgboxText{1} =  strcat('Error saving to file: ', ann_file_name);
        msgbox(msgboxText,'Please try to save again.');
        return;
    end;


    %if (~iscell(comments)),PASerrmsg('Comments must be a cell array','');end;

    %objlabels=sprintf(' "%s"',record.objects(:).label);
    fprintf(fd,'# PHENOLOGY ITU Annotation Version %0.2f\n',VERSION);
    fprintf(fd,'\n');
    fprintf(fd,'Image filename : "%s"\n',char(annotation.file_name));
    %fprintf(fd,'Image size (X x Y x C) : %d x %d x %d\n',record.imgsize);
    %fprintf(fd,'Database : "%s"\n',record.database);
    %fprintf(fd,'Objects with ground truth : %d {%s }\n',nobjs,objlabels);
    fprintf(fd,'\n');
    %if (length(comments)>0),
    %  for i=1:length(comments), fprintf(fd,'# %s\n',char(comments(i))); end;
    %  fprintf(fd,'\n');  
    %end;
    %fprintf(fd,'# Note that there might be other objects in the image\n');
    %fprintf(fd,'# for which ground truth data has not been provided.\n');
    %fprintf(fd,'\n');
    fprintf(fd,'# Top left pixel co-ordinates : (1, 1)\n');

    % The last region is always empty.
    size_regions = size(annotation.regions, 2);
    for i=1:size_regions,
        % We only save the active regions.
        if annotation.regions(i).active == 1
            lbl = char(annotation.regions(i).label);
            bbox = annotation.regions(i).bbox;
            fprintf(fd,'\n# Details for object %d ("%s")\n',i,lbl);
            %fprintf(fd,'Original label for object %d "%s" : "%s"\n',i,lbl,record.objects(i).orglabel);
            fprintf(fd,'Bounding box for object %d "%s" (Xmin, Ymin) - (Xmax, Ymax) : (%d, %d) - (%d, %d)\n',i,lbl,bbox);
            %if (~isempty(record.objects(i).polygon)),
            %  fprintf(fd,'Polygon for object %d "%s" (X, Y) :',i,lbl);
            %  fprintf(fd,' (%d, %d)',record.objects(i).polygon);
            %  fprintf(fd,'\n');
            %end;
            %if (~isempty(record.objects(i).mask)),
            %  fprintf(fd,'Pixel mask for object %d "%s" : "%s"\n',i,lbl, ...
            %         record.objects(i).mask);
            %end;
        end
    end;

    fclose(fd);
    return