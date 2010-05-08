function ret_success = ssh_lck(ssh_struct, file_name, cache_dir, action)
    % Global lock name (for this function)
    file_name_lck = strcat(file_name,'.lck');
    % We need to put something on the lock :)    
    local_host_name = java.net.InetAddress.getLocalHost().getHostName();
    % fail by default
    ret_success = 0;

    if strcmp(action, 'lock')
        % we try to lock the file.  In general if you are locking a file,
        % you should unlock all the files you have locked.

        % FILE LOCKED?
        % We checked if its locked before anything else so we avoid the user
        % having to wait for a download and then realizing he can't edit...
        % The lock will be named filename.lck and will have the hostname in
        % it.
        lock_exists = ssh_exists(ssh_struct, file_name_lck);
        lock_string = '';
        if lock_exists
            lock_string = get_lock_string(ssh_struct, file_name_lck, cache_dir);
        end

        if lock_exists && strcmp(local_host_name, lock_string) == 1
            % the user has the lock, don't create anything and return.
            ret_success = 1;
            return;

        elseif lock_exists && strcmp(local_host_name, lock_string) ~=1
            % there is a lock, tell the user.
            msgboxText{1} = strcat('The filename: ', file_name, ' is locked.', ...
                ' You will have to wait until the lock is released in ', ...
                ' the server');
            msgbox(msgboxText, 'SSH locking failed', 'error');
            return;
        end


        % CREATE LOCK.
        % We unlock all our locked files first.
        % We list the whole content of the directory and create the file list.
        % we use -l so the list is vertical.
        [file_list, pathname] = ssh_getlist(ssh_struct);
        if length(file_list) == 0 ;return; end; % in case of error.

        for i = 1:length(file_list)
            temp = file_list(i);
            if (length(temp) > 4 && strcmp(temp(end-3:end), '.lck') == 1)...
                && stcmp(local_host_name, get_lock_string(ssh_struct, temp, cache_dir)) == 1
                % we should delete the file
                success = ssh_delete(ssh_struct, temp);
                if success == 0
                    return
                end
            end
        end

        % We create a temp file with the lock name...
        local_file_name_lck = [cache_dir, '/', file_name_lck];
        [fd,syserrmsg]=fopen(local_file_name_lck,'wt');
        if (fd==-1),
            msgboxText{1} =  strcat('Error creating lock file: ', ...
                local_file_name_lck, '.  Try again at a latter time.');
            msgbox(msgboxText,'SSH locking failed', 'error');
            ret_success = 0;
            return;
        end;
        fprintf(fd, char(local_host_name));
        fclose(fd);
        % We upload the temp file...
        success = ssh_upload(ssh_struct, local_file_name_lck);
        if ~success; return; end;

        % we delete it locally.
        delete( [cache_dir, '/', file_name_lck]);

        ret_success = 1;
        return

    elseif strcmp(action, 'unlock')
        % we try to unlock the file

        % If there is no lock we return success...
        lock_exists = ssh_exists(ssh_struct, file_name_lck);
        if ~lock_exists
            %Then the file is not really locked :)
            ret_success = 1;
            return
        end

        % If there is a lock file, try to erase it if its from the user.
        lock_string = get_lock_string(ssh_struct, file_name_lck, cache_dir);
        if strcmp(lock_string, local_host_name) == 0
            % the lock is not the users and cannot be unlocked.
            msgboxText{1} = strcat('Trying to unlock a locked file. ', ...
                'You must wait until the file is unlocked.');
            msgbox(msgboxText, 'SSH locking failed', 'error');
            ret_success = 0;
            return
        end

        success = ssh_delete(ssh_struct, file_name_lck);
        if ~success; ret_success = 0; return; end;

        ret_success = 1;
        return

    elseif strcmp(action, 'islocked')
        % it is locked if it is owned by someone else.
        lock_exists = ssh_exists(ssh_struct, file_name_lck);

        if ~lock_exists
            ret_success = 0;
            return;
        end

        ret_success = 1; %a lock exists.
        return;

    elseif strcmp(action, 'ismine')
        % it is locked if it is owned by someone else.
        lock_exists = ssh_exists(ssh_struct, file_name_lck);

        if ~lock_exists
            ret_success = 0;
            return;
        end

        lock_string = get_lock_string(ssh_struct, file_name_lck, cache_dir);
        if strcmp(lock_string, local_host_name) ~= 1
            ret_success = 0;
            return;
        end

        ret_success = 1;
        return;
    else
        %Should not get here.
    end

function ret_string = get_lock_string(ssh_struct, lockname, cache_dir)
    %We need to download the lock, open the file, read the contents, close
    %the file and return. We don't chedk for existence.
    ret_string = '';

    success = ssh_download(ssh_struct, lockname, cache_dir);
    if ~success; return; end;


    [fd,syserrmsg]=fopen( strcat(cache_dir, '/', lockname) );
    if (fd==-1),
        return;
    end;

    line=fgetl(fd);
    if ~ischar(line)
        % contains nothing :(
        fclose(fd);
        return;
    end
    fclose(fd);

    ret_string = line;

    delete( strcat(cache_dir, '/', lockname) );
    return
