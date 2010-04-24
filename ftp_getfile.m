% f     is the ftp stricture.  f.f is where the ftp object is found.
function [ret_file_path, ret_ann_path, ret_ftp] = ftp_getfile(f, file_name, cache_dir)

    % set the default return values.  These should get returned in case of
    % an error.
    ret_file_path = 0;
    ret_ann_path = 0;
    ret_ftp = f;

    % See if we have a good ftp handle.
    try
        pathname = strcat('ftp://', cd(f.f));
    catch exception
        [f, error_m] = ftp_connect;
        if strcmp(error_m, '') ~= 1
            msgboxText{1} =  strcat('FTP error message:',error_m);
            msgbox(msgboxText,'FTP connect failed', 'error');
            return;
        else
            pathname = strcat('ftp://', cd(f.f));
            ret_ftp = f;
        end
    end
    
    % FILE EXISTS?
    % Check if the filename exists in the ftp connection.  We should be in
    % the correct dir.  If dir returns an empty array, the file does not
    % exist.
    if isempty(dir(f.f, file_name))
        % Tell the user the error.
        msgboxText{1} = strcat('I cant seem to find the specified file: ',...
            'filename, ',  'I searched in ftp server: ', f.host, ...
            ' in directory: ', f.dir, '. Make sure you have the right',...
            ' configuration.');
        msgbox(msgboxText, 'FTP retrieve failed', 'error');
        return;
    end
    
    % FILE LOCKED?
    % We checked if its locked before anything else so we avoid the user
    % having to wait for a download and then realizing he can't edit...
    % The lock will be named filename.lck
    file_name_lck = strcat(file_name,'.lck');
    if ~isempty(dir(f.f, file_name_lck))
        % This means there is a lock file.  Tell the user and return
        msgboxText{1} = strcat('The filename: ', file_name, ' is locked.', ...
            ' You will have to wait until the lock is released in ', ...
            ' the server');
        msgbox(msgboxText, 'FTP retrieve failed', 'error');
        return;
    end
    
    % CREATE LOCK
    % from now on we should delete the lock everytime we error out.  Just
    % to be clean...
    % We need to put something on the lock :)
    local_host_name = java.net.InetAddress.getLocalHost().getHostName();
    % We create a temp file with the lock name...
    [fd,syserrmsg]=fopen(file_name_lck,'wt');
    if (fd==-1),
        msgboxText{1} =  strcat('Error creating lock file: ', ...
            file_name_lck, '.  Try again at a latter time.');
        msgbox(msgboxText,'FTP retrieve failed', 'error');
        return;
    end;
    fprintf(fd, char(local_host_name));
    fclose(fd);
    % We upload the temp file...
    try
        mput(f.f, file_name_lck);
        delete(file_name_lck);
    catch exception
        msgboxText{1} =  strcat('Error creating lock file: ', ...
            file_name_lck, '.  Try again at a latter time.', ...
            '  Message: ', exception.message);
        msgbox(msgboxText,'FTP retrieve failed', 'error');
        return;
    end

    % RETRIEVE THE FILE
    % We see if the file is already in cache.  We mget it and put it in the
    % cache if it is not already there.
    if exist( strcat(cache_dir, '/', file_name) ) ~= 2
        % we download it and put it in cache_dir
        try
            mget(f.f, file_name, cache_dir);
        catch exception
            delete(f.f, file_name_lck);
            % Tell the user to try once more....
            msgboxText{1} = strcat('Downloading filename : ', file_name, ...
                ' failed.  Please try again in a few minutes.', ...
                '  Message: ', exception.message);
            msgbox(msgboxText, 'FTP retrieve failed', 'error');
            return;
        end
    end
            
    % RETRIEVE THE ANNOTATION
    % We put it in cache...  It does not matter if there is an error.  If
    % there is no annotation file, one will automatically get created.
    file_name_ann = strcat(file_name,'.ann');
    try
        mget(f.f, file_name_ann, cache_dir);
        ret_ann_path = strcat(cache_dir, '/', file_name_ann);
    catch exception
        % We siliently ignore... :)
        ret_ann_path = '';
    end

    % HURRAY, WE HAVE DOWNLOADED A FILE!!!!
    ret_file_path = strcat(cache_dir, '/', file_name);
    
end