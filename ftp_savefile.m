function [ret_ftp, error_m] = ftp_savefile(f, file_name, cache_dir)

    ret_ftp = f;
    error_m = '';

    % See if we have a good ftp handle.
    try
        pathname = strcat('ftp://', cd(f.f));
    catch exception
        [f, error_m] = ftp_connect;
        if strcmp(error_m, '') ~= 1
            error_m = strcat('FTP error message:',error_m);
            msgboxText{1} =  error_m;
            msgbox(msgboxText,'FTP connect failed', 'error');
            return;
        else
            pathname = strcat('ftp://', cd(f.f));
            ret_ftp = f;
        end
    end

    % CHECK THAT THE FILE EXISTS IN LOCAL
    file_name_path = strcat(cache_dir, '/', file_name);
    if ~exist(file_name_path) == 2
        error_m = strcat('The file:', file_name, ' does not', ...
            ' exist in the local machine.  Your cache is probably', ...
            ' out of sync.  Try to download the file once more');
        msgboxText{1} = error_m;
        msgbox(msgboxText, 'FTP save failed', 'error');
        return;
    end

    % CHECK THAT THE ANNOTATION FILE EXISTS
    file_name_ann = strcat(cache_dir, '/', file_name, '.ann');
    if exist(file_name_ann) == 0
        % then there is no annotation file and there is no point in saving
        error_m = strcat('The file:', file_name_ann, ' does not', ...
            ' exist in the local machine.  You should create an ', ...
            ' annotation and then save.');
        msgboxText{1} = error_m;
        msgbox(msgboxText, 'FTP save failed', 'error');
        return;
    end

    % CHECK THAT THERE IS A LOCK FILE ON SERVER.
    file_name_lck = strcat(file_name, '.lck');
    if ftp_lck(f, file_name, cache_dir, 'islocked') == 0
        % there is no lock file and we should not touch it.
        % then there is no annotation file and there is no point in saving
        error_m = strcat('I found no lock file for file:', file_name, ...
            ' in the server.  Try to open the file once more to get', ...
            ' a lock file.');
        msgboxText{1} = error_m;
        msgbox(msgboxText, 'FTP save failed', 'error');
        return;
    end

    % CHECK THAT THE LOCK FILE IS FROM 'THIS' HOST.
    %FIXME: leave this for later.
    
    % CHANGE THE ANNOTATION FILE ONLY!!!!
    try
        mput(f.f, file_name_ann)
    catch exception
        error_m = strcat('There was an error while saving the', ...
            ' annotation for file:', file_name,'.  Please try', ...
            ' again at a later time.  Message:', ...
            exception.message);
        msgboxText{1} = error_m;
        msgbox(msgboxText, 'FTP save failed', 'error');
        return;
    end

    % DELETE THE LOCK FILE FROM THE SERVER
    if ftp_lck(f, file_name, cache_dir, 'ulock') == 0
        error_m = 'error unlocking';
        return;
    end

    % WE ARE DONE!!!
end
    