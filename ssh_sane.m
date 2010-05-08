function ret_sane = ssh_sane(ssh_struct)
    % The default is failure.
    ret_sane = 0;

    % Check if we can do a simple echo.
    command = ['ssh ', ssh_struct.user, '@', ssh_struct.server, ' echo test'];
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

    elseif strcmp(command_output, 'test') == 0
        % also fishy
        msgboxText{1} =  strcat( 'SSH error message: The output of (echo test) was not test');
        msgbox(msgboxText,'SSH connect failed', 'error');
        return;
    end

    % Check and see if the given dir is valid.
    command = ['ssh ' , ssh_struct.user, '@', ssh_struct.server, ' cd ', ssh_struct.dir];
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




