function [ret_ftp, error_message] = ftp_connect()

    % We read the ftp configuration file
    [server, username, directory] = ftp_config('r', 0, 0, 0);

    % We will always call the ftp gui so the user can put what is missing
    % and the passwd.
    s = ftp_conf_gui(char(server), char(username), char(directory));

    % We handle the error.
    if isempty(s.server) || isempty(s.username) || isempty(s.directory)
        ret_ftp = -1;
        error_message = 'Canceled';
        return;
    end

    % We try to connect using matlabs ftp utility.
    try
        ret_ftp = ftp(s.server, s.username,s.passwd);

    catch exception
        ret_ftp = -1;
        error_message = exception.identifier;
        return;
    end

    % We try to change to the dir that is specified
    try
        cd(ret_ftp, s.directory);
    catch exception
        ret_ftp = -1;
        error_message = exception.identifier;
        return;
    end
    return