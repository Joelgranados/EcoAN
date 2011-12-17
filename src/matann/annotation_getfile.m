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


% This function will gather all the getfile funcitonalities.
function [file_path, success, ret_handles] =...
        annotation_getfile(handles, file_name)
    success = 0;
    file_path = '';
    ret_handles = handles;
    temp_file = char(file_name);

    if exist(temp_file) == 2 %is a file
        file_path = temp_file;

        % Change the state
        handles.curr_ann.ftp = 0;
        handles.curr_ann.ssh = 0;
        ret_handles = handles;

        success = 1;
        return
    end
end
