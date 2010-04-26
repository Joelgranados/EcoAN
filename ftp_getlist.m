function [filename, pathname, ret_ftp] = ftp_getlist(f)

    ret_ftp = f;
    % See if we have a good ftp handle.
    try
        pathname = strcat('ftp://', cd(f.f));
    catch exception
        [f, error_m] = ftp_connect;
        if strcmp(error_m, '') ~= 1
            filename = 0;
            pathname = 0;
            msgboxText{1} =  strcat('FTP error message:',error_m);
            msgbox(msgboxText,'FTP connect failed', 'error');
            return;
        else
            pathname = strcat('ftp://', cd(f.f));
            ret_ftp = f;
        end
    end

    % get the dir list.  We assume that the ftp handle is on the correct
    % dir.
    dir_list = dir(f.f);
    
    % construct the filename array.  We will not include stuff that is not
    % a file.  We will not include stuff that ends with .ann.
    filename = [];
    for i = 1:length(dir_list)

        % We don't want dirs.
        if dir_list(i).isdir == 1 ...
                || (length(dir_list) > 4 ...
                    && strcmp(dir_list(i).name(end-3:end), '.ann') == 1)
            continue;
        end

        filename = [filename, cellstr(dir_list(i).name)];
    end
end