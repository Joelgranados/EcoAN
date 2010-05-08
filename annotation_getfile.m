
% This function will gather all the getfile funcitonalities.
function [file_path, success, ret_handles] =...
        annotation_getfile(handles, file_name)
    success = 0;
    file_path = '';
    ret_handles = handles;
    temp_file = char(file_name);
    
    % We check for ftp, ssh and local.
    if length(temp_file) > 6 && strcmp(temp_file(1:6), 'ftp://') == 1
        % then its an ftp file.
        % We first make sure we put it in the cache...
        [file_path, ann_path, handles.ftp_struct] =...
            ftp_getfile(handles.ftp_struct, temp_file(7:end),...
            handles.config.cache_dir);

        % if it failes we return..
        if ~file_path;return;end;

        % Change the state.
        handles.curr_ann.ftp = 1;
        handles.curr_ann.ssh = 0;
        ret_handles = handles;

        success = 1;
        return;
    elseif length(temp_file) > 6 && strcmp(temp_file(1:6), 'ssh://') == 1
        [file_path, ap] = ssh_getfile(handles.ssh_struct,...
            temp_file(7:end), handles.config.cache_dir);
        
        if ~file_path; return; end;
        
        % Change the state
        handles.curr_ann.ftp = 0;
        handles.curr_ann.ssh = 1;
        ret_handles = handles;

        success = 1;
        return

    elseif exists(temp_file) == 2 %is a file
        file_path = temp_file;

        % Change the state
        handles.curr_ann.ftp = 0;
        handles.curr_ann.ssh = 0;
        ret_handles = handles;

        success = 1;
        return
    end
end
