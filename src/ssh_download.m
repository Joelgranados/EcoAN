function ret_val = ssh_download(ssh_struct, file_name, local_dir)
    % The default is error.
    ret_val = 0;

    % Make sure we have a good connection. We already showed the error.
    if  ssh_sane(ssh_struct) == 0; return; end;

    % We list the whole content of the directory and create the file list.
    % we use -l so the list is vertical.
    command = ['scp ', ssh_struct.username, '@', ssh_struct.server,...
            ':', ssh_struct.dir, '/', file_name, ' ', local_dir];
    [s, w] = unix(command);

    % Check the status.
    if s > 0
        % Then something is going on, tell the user.
        msgboxText{1} =  strcat( 'SSH error message: ', w );
        msgbox(msgboxText,'SSH download failed', 'error');
        return;
    end

    ret_val = 1;
    return
end

