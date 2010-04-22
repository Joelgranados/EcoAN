function [ret_server, ret_username, ret_dir] =...
        ftp_config(action, server, username, directory)
    ret_server = -1;
    ret_username = -1;
    ret_dir = -1;

    ftp_conf_file='ftp.configuration';
    if strcmp(action, 'r') == 1
        %We read
        [fd,syserrmsg]=fopen(ftp_conf_file,'rt');
        if (fd==-1)
           return;
        end

        while 1
            line=fgetl(fd);
            EOF=~ischar(line);
            if EOF
                break;
            end

            % Lets ignore stuff, we are interested in lines that start with
            % 's', 'd' or 'u'
            if length(line) >= 7 && strcmp(line(1:6),'server') == 1
                ret_server = line(8:end);
            elseif length(line) >= 4 && strcmp(line(1:3), 'dir') == 1
                ret_dir = line(5:end);
            elseif length(line) >= 9 && strcmp(line(1:8), 'username') == 1
                ret_username = line(10:end);
            end
        end
        fclose(fd);
        return;

    elseif strcmp(action, 'w') == 1
        %We write
        [fd,syserrmsg]=fopen(ftp_conf_file,'wt');
        if (fd==-1),
            return;
        end
        fprintf(fd, '# Configuration file for fpt connection\n');
        fprintf(fd, '# Lines starting with "#" are ignored\n');
        fprintf(fd, '# Lines starting with a space or tab sre ignored.\n');
        fprintf(fd, '# Only "server", "dir" and "username" are keys for now.\n');
        fprintf(fd, 'server=%s\n', server);
        fprintf(fd, 'dir=%s\n', directory);
        fprintf(fd, 'username=%s\n', username);

        fclose(fd);
        ret_server = server;
        ret_username = username;
        ret_dir = dir;
        return;

    else
        %Nothing.
    end
