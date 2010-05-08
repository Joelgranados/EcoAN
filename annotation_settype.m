function ret_ann = annotation_settype(file_name, ann)
    temp_file = char(file_name);
    % We check for ftp, ssh and local.
    if length(temp_file) > 6 && strcmp(temp_file(1:6), 'ftp://') == 1
        ann.ftp = 1;
        ann.ssh = 0;
    elseif length(temp_file) > 6 && strcmp(temp_file(1:6), 'ssh://') == 1
        ann.ftp = 0;
        ann.ssh = 1;
    elseif exists(temp_file) == 2 %is a file
        ann.ftp = 0;
        ann.ssh = 0;
    end
    
    ret_ann = ann;
end