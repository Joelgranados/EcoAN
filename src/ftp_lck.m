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


function ret_success = ftp_lck(f, file_name, cache_dir, action)
    % Global lock name (for this function)
    file_name_lck = strcat(file_name,'.lck');
    % We need to put something on the lock :)    
    local_host_name = java.net.InetAddress.getLocalHost().getHostName();


    if strcmp(action, 'lock')
        % we try to lock the file.  N general if you are locking a file,
        % you should unlock all the files you have locked.

        % FILE LOCKED?
        % We checked if its locked before anything else so we avoid the user
        % having to wait for a download and then realizing he can't edit...
        % The lock will be named filename.lck and will have the hostname in
        % it.

        if ~isempty(dir(f.f, file_name_lck)) ...
                && strcmp(local_host_name, ...
                   get_lock_string(f, file_name_lck, cache_dir)) == 0
            % This means there is a lock file.  Tell the user and return
            msgboxText{1} = strcat('The filename: ', file_name, ' is locked.', ...
                ' You will have to wait until the lock is released in ', ...
                ' the server');
            msgbox(msgboxText, 'FTP locking failed', 'error');
            ret_success = 0;
            return;
        end

        % CREATE LOCK.
        % We unlock all our locked files first.
        lock_files = dir(f.f);
        for i = 1:length(lock_files)
            if strcmp( lock_files(i).name(end-3:end), '.lck') ~= 1
                continue;
            end

            contents = get_lock_string(f, lock_files(i).name, cache_dir);
            if strcmp(contents, local_host_name) == 1
                % should delete the lock
                delete(f.f, lock_files(i).name);
            end
        end

        % We create a temp file with the lock name...
        [fd,syserrmsg]=fopen(file_name_lck,'wt');
        if (fd==-1),
            msgboxText{1} =  strcat('Error creating lock file: ', ...
                file_name_lck, '.  Try again at a latter time.');
            msgbox(msgboxText,'FTP locking failed', 'error');
            ret_success = 0;
            return;
        end;
        fprintf(fd, char(local_host_name));
        fclose(fd);
        % We upload the temp file...
        try
            mput(f.f, file_name_lck);
            delete(file_name_lck); % we delete it locally.
        catch exception
            msgboxText{1} =  strcat('Error creating lock file: ', ...
                file_name_lck, '.  Try again at a latter time.', ...
                '  Message: ', exception.message);
            msgbox(msgboxText,'FTP locking failed', 'error');
            ret_success = 0;
            return;
        end

        ret_success = 1;
        return

    elseif strcmp(action, 'ulock')
        % we try to unlock the file

        % If there is no lock we return success...
        if isempty(dir(f.f, file_name_lck))
            %Then the file is not really locked :)
            ret_success = 1;
            return
        end

        % If there is a lock file, try to erase it.
        try
            delete(f.f, file_name_lck)
            ret_success = 0;
            return;
        catch exception
            msgboxText{1} = strcat('There was a problem unlocking ', ...
                'file: ', file_name, '.  Please contact the admin.', ...
                ' Message:', exception.message);
            msgbox(msgboxText, 'FTP locking failed', 'error');
            ret_success = 0;
            return
        end

        % Should never get here.

    elseif strcmp(action, 'islocked')
        if isempty(dir(f.f, file_name_lck))
            %Then the file is not really locked :)
            ret_success = 0;
            return
        end

        ret_success = 1;
        return

    else
        %Should not get here.
    end

function ret_string = get_lock_string(f, lockname, cache_dir)
    %We need to download the lock, open the file, read the contents, close
    %the file and return.
    ret_string = '';

    try
        mget(f.f, lockname, cache_dir);
    catch exception
        return
    end

    [fd,syserrmsg]=fopen( strcat(cache_dir, '/', lockname) );
    if (fd==-1),
        return;
    end;

    line=fgetl(fd);
    if ~ischar(line)
        % contains nothing :(
        close(fd);
        return;
    end

    ret_string = line;

    delete( strcat(cache_dir, '/', lockname) );
    return
