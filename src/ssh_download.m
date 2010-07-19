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

