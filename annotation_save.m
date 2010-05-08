function annotation_save(handles, annotation)

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

    % The last region is always empty.
    size_regions = size(annotation.regions, 2);
    for i=1:size_regions,
        % We only save the active regions.
        if annotation.regions(i).active == 1
            lbl = char(annotation.regions(i).label);
            bbox = annotation.regions(i).bbox;
            fprintf(fd,'\n# Details for object %d ("%s")\n',i,lbl);
            fprintf(fd,'Bounding box for object %d "%s" (Xmin, Ymin) - (Xmax, Ymax) : (%d, %d) - (%d, %d)\n',i,lbl,bbox);

        end
    end;

    fclose(fd);
    
    % WE SEE IF WE HAVE TO SAVE TO SERVER.
    [path, file_name, extension] = fileparts(handles.curr_ann.file_name);
    file_name = strcat(file_name, extension);
    if annotation.ftp == 1
        % then we save to ftp. :)
        [ret_ftp, error_m] = ftp_savefile(handles.ftp_struct, ...
            file_name, handles.config.cache_dir);

        % FIXME : Handle the possible error.  It has already given a 
        % message.

    elseif annotation.ssh == 1
        % then save using ssh. :)
        ret_val = ssh_savefile(handles.ssh_struct, file_name,...
            handles.config.cache_dir);
    end
end
