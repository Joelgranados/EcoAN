% Annotatio:n.  An annotation creation tool for images.
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


function ret_val = ssh_savefile(ssh_struct, file_name, cache_dir)
    ret_val = 0;

    % Make sure we have a good connection. We already showed the error.
    if  ssh_sane(ssh_struct) == 0; return; end;

    % CHECK THAT THE FILE EXISTS IN LOCAL
    file_name_path = strcat(cache_dir, '/', file_name);
    if ~exist(file_name_path) == 2
        error_m = strcat('The file:', file_name, ' does not', ...
            ' exist in the local machine.  Your cache is probably', ...
            ' out of sync.  Try to download the file once more');
        msgboxText{1} = error_m;
        msgbox(msgboxText, 'SSH save failed', 'error');
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
        msgbox(msgboxText, 'SSH save failed', 'error');
        return;
    end

    % CHECK THAT THERE IS A LOCK FILE ON SERVER.
    if ssh_lck(ssh_struct, file_name, cache_dir, 'islocked') == 0
        % There is a lock and its not owned by the user.
        error_m = strcat('I found no lock file for file:', file_name, ...
            ' in the server.  You must own a lock to save a file.');
        msgboxText{1} = error_m;
        msgbox(msgboxText, 'FTP save failed', 'error');
        return;
        
    elseif ssh_lck(ssh_struct, file_name, cache_dir, 'ismine') == 0
        % There is a lock and its not owned by the user.
        error_m = strcat('I found a lock from a different user :',...
            'for filename:', file_name, '.  You must own a lock',...
            'to save a file.');
        msgboxText{1} = error_m;
        msgbox(msgboxText, 'FTP save failed', 'error');
        return;
    end

    % CHANGE THE ANNOTATION FILE ONLY!!!!
    if ssh_upload(ssh_struct, file_name_ann) == 0; return; end;

    % DELETE THE LOCK FILE FROM THE SERVER
    if ssh_lck(ssh_struct, file_name, cache_dir, 'unlock') == 0; return; end;

    % WE ARE DONE!!!
    ret_val = 1;
end
