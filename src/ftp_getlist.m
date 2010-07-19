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


function [filename, pathname, ret_ftp] = ftp_getlist(f)

    ret_ftp = f;
    % See if we have a good ftp handle.
    try
        cd(f.f);
    catch exception
        [f, error_m] = ftp_connect;
        if strcmp(error_m, '') ~= 1
            filename = 0;
            pathname = 0;
            msgboxText{1} =  strcat('FTP error message:',error_m);
            msgbox(msgboxText,'FTP connect failed', 'error');
            return;
        else
            cd(f.f);
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
                || (length(dir_list(i).name) > 4 ...
                    && (strcmp(dir_list(i).name(end-3:end), '.ann') == 1 ...
                        || strcmp(dir_list(i).name(end-3:end), '.lck') == 1))
            continue;
        end

        filename = [filename, cellstr(dir_list(i).name)];
        pathname = 'ftp://';
    end
end
