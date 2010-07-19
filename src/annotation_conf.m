% Annotation.  An annotation creation tool for images.
% Copyright (C) 2010 Joel Granados <joel.granados@gmail.com>
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

function conf_struct = annotation_conf(conf_file, input_conf_struct, action)
    conf_struct.ftp_server = -1;
    conf_struct.ftp_username = -1;
    conf_struct.ftp_dir = -1;
    conf_struct.cache_dir = -1;

    if isempty(conf_file)
        conf_file='annotation.conf';
    end

    if strcmp(action, 'r') == 1
        %We read
        [fd,syserrmsg]=fopen(conf_file,'rt');
        if (fd==-1)
           return;
        end

        while 1
            line=fgetl(fd);
            EOF=~ischar(line);
            if EOF
                break;
            end

            % Lets ignore stuff
            if length(line) >= 11 && strcmp(line(1:10),'ftp_server') == 1
                conf_struct.ftp_server = line(12:end);

            elseif length(line) >= 8 && strcmp(line(1:7), 'ftp_dir') == 1
                conf_struct.ftp_dir = line(9:end);

            elseif length(line) >= 13 && strcmp(line(1:12), 'ftp_username') == 1
                conf_struct.ftp_username = line(14:end);

            elseif length(line) >= 10 && strcmp(line(1:9), 'cache_dir') == 1
                conf_struct.cache_dir = line(11:end);

            elseif length(line) >= 11 && strcmp(line(1:10), 'ssh_server') == 1
                conf_struct.ssh_server = line(12:end);

            elseif length(line) >= 13 && strcmp(line(1:12), 'ssh_username') == 1
                conf_struct.ssh_username = line(14:end);

            elseif length(line) >= 8 && strcmp(line(1:7), 'ssh_dir') == 1
                conf_struct.ssh_dir = line(9:end);
            end
        end
        fclose(fd);
        return;

    elseif strcmp(action, 'w') == 1
        %We write
        [fd,syserrmsg]=fopen(conf_file,'wt');
        if (fd==-1),
            return;
        end
        fprintf(fd, '# Configuration file for fpt connection\n');
        fprintf(fd, '# Lines starting with "#" are ignored\n');
        fprintf(fd, '# Lines starting with a space or tab sre ignored.\n');
        fprintf(fd, '# Only "ftp_server", "dir" and "username" are keys for now.\n');
        fprintf(fd, 'ftp_server=%s\n', input_conf_struct.server);
        fprintf(fd, 'ftp_dir=%s\n', input_conf_struct.directory);
        fprintf(fd, 'ftp_username=%s\n', input_conf_struct.username);

        fclose(fd);
        return;

    else
        %Nothing.
    end
