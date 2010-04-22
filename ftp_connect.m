function [ret_ftp, ret_dir] = ftp_connect()

    % We read the ftp configuration file
    [server, username, directory] = ftp_config('r', 0, 0, 0);

    % We will always call the ftp gui so the user can put what is missing
    % and the passwd.
    s = ftp_conf_gui(char(server), char(username), char(directory));

    % We handle the error.
    if isempty(s.server) || isempty(s.username) || isempty(s.directory)
        ret_ftp = -1;
        ret_dir = -1;
        return;
    end

    % We try to connect using matlabs ftp utility.
    ret_ftp = ftp(s.server,s.username,s.passwd);

    ret_dir = s.directory;
    return
