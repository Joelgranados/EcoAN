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


function ret_ann = annotation_settype(file_name, ann)
    temp_file = char(file_name);
    % We check for ftp, ssh and local.
    if length(temp_file) > 6 && strcmp(temp_file(1:6), 'ftp://') == 1
        ann.ftp = 1;
        ann.ssh = 0;
    elseif length(temp_file) > 6 && strcmp(temp_file(1:6), 'ssh://') == 1
        ann.ftp = 0;
        ann.ssh = 1;
    elseif exist(temp_file) == 2 %is a file
        ann.ftp = 0;
        ann.ssh = 0;
    end

    ret_ann = ann;
end
