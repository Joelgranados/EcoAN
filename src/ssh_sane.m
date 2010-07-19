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


function ret_sane = ssh_sane(ssh_struct)
    % The default is failure.
    ret_sane = 0;

    % Check if we can do a simple echo.
    command = ['ssh ', ssh_struct.username, '@', ssh_struct.server, ' echo test'];
    eo = java.lang.Runtime.getRuntime().exec(command);
    eb = java.io.BufferedReader(java.io.InputStreamReader(eo.getErrorStream()));
    ob = java.io.BufferedReader(java.io.InputStreamReader(eo.getInputStream()));

    command_error = char(eb.readLine());
    command_output = char(ob.readLine());
    eo.destroy();

    if ~isempty(command_error)
        % Fishy fishy
        msgboxText{1} =  strcat( 'SSH error message: ', command_error );
        msgbox(msgboxText,'SSH connect failed', 'error');
        return;

    elseif strcmp(command_output, 'test') == 0
        % also fishy
        msgboxText{1} =  strcat( 'SSH error message: The output of (echo test) was not test');
        msgbox(msgboxText,'SSH connect failed', 'error');
        return;
    end

    % Check and see if the given dir is valid.
    command = ['ssh ' , ssh_struct.username, '@', ssh_struct.server, ' cd ', ssh_struct.dir];
    eo = java.lang.Runtime.getRuntime().exec(command);
    eb = java.io.BufferedReader(java.io.InputStreamReader(eo.getErrorStream()));
    ob = java.io.BufferedReader(java.io.InputStreamReader(eo.getInputStream()));

    command_error = eb.readLine();
    command_output = ob.readLine();
    eo.destroy();

     if ~isempty(command_error)
        % Fishy fishy
        msgboxText{1} =  strcat( 'SSH error message: ', command_error );
        msgbox(msgboxText,'SSH connect failed', 'error');
        return;
    end

    ret_sane = 1;
    return;
end




