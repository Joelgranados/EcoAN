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

CMAKE_MINIMUM_REQUIRED (VERSION 2.8)

# PROJECT METADATA STUFF
PROJECT (Annotation)
SET (EIP_AUTHOR "Joel Andres Granados <joel.granados@gmail.com>")
SET (EIP_DESCRIPTION "Annotation annotates image sequences.")
SET (EIP_NAME "Annotation")
SET (EIP_NAME_SHORT "Ann")
SET (EIP_LICENSE "GPL-3")
SET (EIP_VER_MAJOR 0)
SET (EIP_VER_MINOR 1)

# SANITY CHECK ENVIRONMENT
IF(UNIX)
    INCLUDE (FindPkgConfig)
    INCLUDE (FindGit)
    pkg_search_module (EXIV2 exiv2 REQUIRED)

    FIND_PACKAGE (PythonLibs REQUIRED)
    INCLUDE_DIRECTORIES(${PYTHON_INCLUDE_PATH})
ELSE(UNIX)
    MESSAGE (FATAL_ERROR
        "FIXME: Need to find python3 and exiv2 on other plotforms." )
ENDIF(UNIX)

# MAIN TARGET
ADD_LIBRARY ( annexif SHARED src/pyann/annexif.cpp )
SET_TARGET_PROPERTIES ( annexif PROPERTIES PREFIX "" )
SET_TARGET_PROPERTIES ( annexif PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/pyann" )

TARGET_LINK_LIBRARIES ( annexif ${EXIV2_LIBRARIES} )

file (COPY "${PROJECT_SOURCE_DIR}/src/pyann" DESTINATION "${PROJECT_BINARY_DIR}")
file (COPY "${PROJECT_SOURCE_DIR}/src/matann" DESTINATION "${PROJECT_BINARY_DIR}")

# TEST TARGET
FILE(COPY "${PROJECT_SOURCE_DIR}/tests" DESTINATION "${PROJECT_BINARY_DIR}")
ADD_CUSTOM_TARGET ( test
    COMMAND ${CMAKE_COMMAND} -E echo "====== STARTING TEST SUITE ======"
    COMMAND ${CMAKE_COMMAND} -E
            copy "${CMAKE_CURRENT_BINARY_DIR}/pyann/annexif.so"
                 "${CMAKE_CURRENT_BINARY_DIR}/tests"
    COMMAND ${CMAKE_COMMAND} -E
            copy "${CMAKE_CURRENT_BINARY_DIR}/pyann/annData.py"
                 "${CMAKE_CURRENT_BINARY_DIR}/tests"
    COMMAND ${CMAKE_COMMAND} -E chdir "${CMAKE_CURRENT_BINARY_DIR}/tests" ./test
    COMMAND ${CMAKE_COMMAND} -E echo "====== ENDING TEST SUITE ======" )
add_dependencies(test annexif)

# HTML5 TARGET.
FILE ( MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/Ann" )

CONFIGURE_FILE( "${PROJECT_SOURCE_DIR}/src/html5ann/ann.html"
                "${PROJECT_BINARY_DIR}/Ann/ann.html" )
CONFIGURE_FILE( "${PROJECT_SOURCE_DIR}/src/html5ann/zoom-pan.js"
                "${PROJECT_BINARY_DIR}/Ann/zoom-pan.js" )
FILE( COPY "${PROJECT_SOURCE_DIR}/src/raphael/raphael.js"
      DESTINATION "${PROJECT_BINARY_DIR}/Ann/" )
