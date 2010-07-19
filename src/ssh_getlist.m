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


function [filename, pathname] = ssh_getlist(ssh_struct)

    % The default is error.
    filename = 0;
    pathname = 0;

    % Make sure we have a good connection. We already showed the error.
    if  ssh_sane(ssh_struct) == 0; return; end;

    % We list the whole content of the directory and create the file list.
    % we use -l so the list is vertical.
    command = ['ssh ', ssh_struct.username, '@', ssh_struct.server,...
            ' ls -1 ', ssh_struct.dir];
    [s, w] = unix(command);

    % Check the status.
    if s > 0
        % Then something is going on, tell the user.
        msgboxText{1} =  strcat( 'SSH error message: ', w );
        msgbox(msgboxText,'SSH command failed', 'error');
        return;
    end

    % sprintf('\n') is the only way I know to represent \n in matlab.
    filename = [];
    [token, remain] = strtok(w, sprintf('\n'));
    while ~isempty(token)
        if (length(token) > 4 && strcmp(token(end-3:end), '.png') == 1)
            filename = [filename, cellstr(token)];

        end

        [token, remain] = strtok(remain, sprintf('\n'));
    end
    pathname = 'ssh://';
end
