function ret_success = ftp_lck(f, file_name, cache_dir, action)
    % Global lock name (for this function)
    file_name_lck = strcat(file_name,'.lck');


    if strcmp(action, 'lock')
        % we try to lock the file

        % FILE LOCKED?
        % We checked if its locked before anything else so we avoid the user
        % having to wait for a download and then realizing he can't edit...
        % The lock will be named filename.lck

        if ~isempty(dir(f.f, file_name_lck))
            % This means there is a lock file.  Tell the user and return
            msgboxText{1} = strcat('The filename: ', file_name, ' is locked.', ...
                ' You will have to wait until the lock is released in ', ...
                ' the server');
            msgbox(msgboxText, 'FTP locking failed', 'error');
            ret_success = 0;
            return;
        end

        % CREATE LOCK.
        % We need to put something on the lock :)
        local_host_name = java.net.InetAddress.getLocalHost().getHostName();
        % We create a temp file with the lock name...
        [fd,syserrmsg]=fopen(file_name_lck,'wt');
        if (fd==-1),
            msgboxText{1} =  strcat('Error creating lock file: ', ...
                file_name_lck, '.  Try again at a latter time.');
            msgbox(msgboxText,'FTP locking failed', 'error');
            ret_success = 0;
            return;
        end;
        fprintf(fd, char(local_host_name));
        fclose(fd);
        % We upload the temp file...
        try
            mput(f.f, file_name_lck);
            delete(file_name_lck); % we delete it locally.
        catch exception
            msgboxText{1} =  strcat('Error creating lock file: ', ...
                file_name_lck, '.  Try again at a latter time.', ...
                '  Message: ', exception.message);
            msgbox(msgboxText,'FTP locking failed', 'error');
            ret_success = 0;
            return;
        end

        ret_success = 1;
        return
        
    elseif strcmp(action, 'ulock')
        % we try to unlock the file
        
        % If there is no lock we return success...
        if isempty(dir(f.f, file_name_lck))
            %Then the file is not really locked :)
            ret_success = 1;
            return
        end
        
        % If there is a lock file, try to erase it.
        try
            delete(f.f, file_name_lck)
            ret_success = 0;
            return
        catch exception
            msgboxText{1} = strcat('There was a problem unlocking ', ...
                'file: ', file_name, '.  Please contact the admin.', ...
                ' Message:', exception.message);
            msgbox(msgboxText, 'FTP locking failed', 'error');
            ret_success = 0;
            return
        end
    
        % Should never get here.

    elseif strcmp(action, 'islocked')
        if isempty(dir(f.f, file_name_lck))
            %Then the file is not really locked :)
            ret_success = 0;
            return
        end

        ret_success = 1;
        return

    else
        %Should not get here.
    end
