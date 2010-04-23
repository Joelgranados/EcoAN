function [filename, pathname] = ftp_getlist(f)

    % See if we have a good ftp handle.
    try
        pathname = strcat('ftp://', cd(f));
    catch exception
        [f, error_m] = ftp_connect;
        if strcmp(error_m, '') ~= 1
            filename = 0;
            pathname = 0;
            msgboxText{1} =  strcat('FTP error message:',error_m);
            msgbox(msgboxText,'FTP connect failed', 'error');
            return;
        else
            pathname = strcat('ftp://', cd(f));
        end
    end

    % get the dir list.  We assume that the ftp handle is on the correct
    % dir.
    dir_list = dir(f);
    
    % construct the filename array.  We will not include stuff that is not
    % a file.
    filename = [];
    for i = 1:length(dir_list)

        % We don't want dirs.
        if dir_list(i).isdir == 1
            continue;
        end

        filename = [filename, cellstr(dir_list(i).name)];
    end
end