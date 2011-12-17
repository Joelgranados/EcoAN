# Annotation.  An annotation creation tool for images.
# Copyright (C) 2011 Joel Granados <joel.granados@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

cmake_minimum_required (VERSION 2.8)

project (Annotation)

find_package (PythonLibs REQUIRED)
include (FindPkgConfig)
pkg_search_module (EXIV2 exiv2 REQUIRED)

include_directories ( ${PYTHON_INCLUDE_PATH} )

add_library ( annexif SHARED src/pyann/annexif.cpp )
set_target_properties ( annexif PROPERTIES PREFIX "" )
set_target_properties ( annexif PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/pyann" )

target_link_libraries ( annexif ${EXIV2_LIBRARIES} )

file (COPY "${PROJECT_SOURCE_DIR}/src/pyann" DESTINATION "${PROJECT_BINARY_DIR}")
