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

function [ret_ftp, error_message] = ftp_connect()

    % We read the ftp configuration file
    conf_struct = annotation_conf('annotation.conf', 0, 'r');
    server = conf_struct.ftp_server;
    username = conf_struct.ftp_username;
    directory = conf_struct.ftp_dir;

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
        ret_ftp.f = ftp(s.server, s.username,s.passwd);
        ret_ftp.host = s.server;
        ret_ftp.username = s.username;
        ret_ftp.passwd = s.passwd;
        ret_ftp.dir = s.directory;

    catch exception
        ret_ftp = -1;
        error_message = exception.identifier;
        return;
    end

    % We try to change to the dir that is specified
    try
        cd(ret_ftp.f, s.directory);
    catch exception
        close(ret_ftp.f);
        ret_ftp = -1;
        error_message = exception.identifier;
        return;
    end
    error_message = '';
    return;
