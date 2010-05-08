function ret_val = ssh_exists(ssh_struct, file_name)
    % The default is error.
    ret_val = 0;

    % Make sure we have a good connection. We already showed the error.
    if  ssh_sane(ssh_struct) == 0; return; end;

    % We list the whole content of the directory and create the file list.
    % we use -l so the list is vertical.
    command = ['ssh ', ssh_struct.user, '@', ssh_struct.server,...
            ' ls ', ssh_struct.dir, '/', file_name];
    [s, w] = unix(command);

    % Check the status.
    if s > 0
        return;

    % deblank for the trailing spaces.
    elseif strcmp (deblank(w(end-length(file_name):end)), file_name) ~= 1
        return;
    end

    ret_val = 1;
    return
end

