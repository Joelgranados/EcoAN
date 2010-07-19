function [ret_file_path, ret_ann_path] = ssh_getfile(ssh_struct, file_name, cache_dir)

    % set the default return values.  These should get returned in case of
    % an error.
    ret_file_path = 0;
    ret_ann_path = 0;

    % Make sure we have a good connection. We already showed the error.
    if  ssh_sane(ssh_struct) == 0; return; end;

    % FILE EXISTS?
    % Check if the filename exists
    file_exists = ssh_exists(ssh_struct, file_name);
    if ~file_exists
        % file was not found
        msgboxText{1} = strcat('I cant seem to find the specified file: ',...
            file_name,  '. I searched in directory', ...
            f.dir, '. Make sure you have the right',...
            ' configuration.');
        msgbox(msgboxText, 'SSH retrieve failed', 'error');
        return;
    end


    % LOCK FILE
    if ~ssh_lck(ssh_struct, file_name, cache_dir, 'lock')
        % there was an issue locking.  There was already a message error.
        % And we will return failed values.  Just return.
        return
    end


    % DOWNLOAD FILE
    if exist( strcat(cache_dir, '/', file_name) ) ~= 2
        if ~ssh_download(ssh_struct, file_name, cache_dir)
            return;
        end
    end

    % DOWNLOAD THE ANNOTATION
    file_name_ann = strcat(file_name,'.ann');
    ann_exists = ssh_exists(ssh_struct, file_name_ann);
    if ann_exists
        if ~ssh_download(ssh_struct, file_name_ann, cache_dir)
            return;
        end

    else
        % we create the annotation localy just in case.
        local_file_name_ann = [cache_dir, '/', file_name_ann];
        [fd,syserrmsg]=fopen(local_file_name_ann,'wt');
        if (fd==-1),
            msgboxText{1} =  strcat('Error downloading annotation file: ', ...
                local_file_name_ann, '.  Try again at a latter time.');
            msgbox(msgboxText,'SSH download failed', 'error');
            ret_success = 0;
            return;
        end;
        fclose(fd);
    end

    % HURRAY, WE HAVE DOWNLOADED A FILE!!!!
    ret_ann_path = strcat(cache_dir, '/', file_name_ann);
    ret_file_path = strcat(cache_dir, '/', file_name);

end
