################################################################################
# Project:  Lib iconv
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

project(iconv C)

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE INTERNAL "Installation directory for executables" FORCE)
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE INTERNAL "Installation directory for libraries" FORCE)
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE INTERNAL "Installation directory for headers" FORCE)

include(util)
set(ICONV_MAJOR_VERSION -1)
set(ICONV_MINOR_VERSION -1)
check_version(ICONV_MAJOR_VERSION ICONV_MINOR_VERSION)
set(VERSION ${ICONV_MAJOR_VERSION}.${ICONV_MINOR_VERSION})

include(configure)

configure_file(${CMAKE_MODULE_PATH}/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)

include_directories ( ${CMAKE_CURRENT_SOURCE_DIR} )
include_directories ( ${CMAKE_CURRENT_BINARY_DIR} )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/include )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/srclib )
include_directories ( ${CMAKE_CURRENT_BINARY_DIR}/include )

#add_definitions ( -DINSTALLPREFIX=NULL -DNO_XMALLOC -DBUILDING_LIBCHARSET -DINSTALLDIR="" )
if(${ENABLE_RELOCATABLE})
    add_definitions ( -Dset_relocation_prefix=libcharset_set_relocation_prefix -Drelocate=libcharset_relocate -DENABLE_RELOCATABLE=1 )
else()
    add_definitions ( -DENABLE_RELOCATABLE=0 )
endif()

set(PUBLIC_HDRS
    ${CMAKE_CURRENT_BINARY_DIR}/include/iconv.h
)

set(PRIVATE_HDRS
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    ${CMAKE_CURRENT_BINARY_DIR}/include/libcharset.h
    ${CMAKE_CURRENT_BINARY_DIR}/include/localcharset.h
    libcharset/lib/relocatable.h
)

set(SRCS
    lib/iconv.c
    libcharset/lib/localcharset.c
    libcharset/lib/relocatable.c
)

if(WIN32)

    if(BUILD_SHARED_LIBS)
        set(SRCS ${SRCS} 
            windows/libiconv.rc
        )
        add_definitions(-DBUILDING_DLL)
        add_definitions (-DPACKAGE_VERSION_MAJOR=${ICONV_MAJOR_VERSION})
        add_definitions (-DPACKAGE_VERSION_MINOR=${ICONV_MINOR_VERSION}) 
        add_definitions (-DPACKAGE_VERSION_SUBMINOR=0) 
        add_definitions (-DPACKAGE_VERSION_STRING="lib${PROJECT_NAME}-${VERSION}")    
    endif()
    
    if (MSVC)
        # -D_UNICODE -DUNICODE 
        add_definitions (-D_CRT_NONSTDC_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NON_CONFORMING_SWPRINTFS -D_CRT_SECURE_NO_DEPRECATE -DLIBDIR="")
    endif()
endif()

add_definitions(-DIN_LIBRARY -DBUILDING_LIBICONV) # -DLIBICONV_PLUG

report_version(${PROJECT_NAME} ${VERSION})     

if(BUILD_SHARED_LIBS)
    set(LIB_NAME ${PROJECT_NAME})
    add_library(${LIB_NAME} SHARED ${SRCS} ${PUBLIC_HDRS} ${PRIVATE_HDRS})
    set_target_properties(${LIB_NAME} PROPERTIES DEFINE_SYMBOL XML2_DLL)
    set_target_properties(${LIB_NAME} PROPERTIES SOVERSION 1)
else()    
    set(LIB_NAME ${PROJECT_NAME}static)
    add_library(${LIB_NAME} STATIC ${SRCS} ${PUBLIC_HDRS} ${PRIVATE_HDRS})
    set_target_properties(${LIB_NAME} PROPERTIES SOVERSION 1)
endif()   

export(TARGETS ${LIB_NAME} FILE ${LIB_NAME}-exports.cmake)
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

if(NOT CYGWIN)
    set_target_properties(${LIB_NAME} PROPERTIES VERSION ${VERSION})
endif()

if(UNIX)
    # On unix-like platforms the library is almost always called lib${PROJECT_NAME}
    set_target_properties(${LIB_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME})
#    if(NOT APPLE AND BUILD_SHARED_LIBS)
#        set_target_properties(${LIB_NAME} PROPERTIES LINK_FLAGS "-Wl,--version-script,\"${CMAKE_CURRENT_SOURCE_DIR}/liblzma.map\"")
#    endif()
endif()

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${LIB_NAME} 
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}" )
endif()
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${PUBLIC_HDRS} DESTINATION "${INSTALL_INC_DIR}")
endif()

