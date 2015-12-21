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

function(from_hex HEX DEC)
  string(TOUPPER "${HEX}" HEX)
  set(_res 0)
  string(LENGTH "${HEX}" _strlen)

  while (_strlen GREATER 0)
    math(EXPR _res "${_res} * 16")
    string(SUBSTRING "${HEX}" 0 1 NIBBLE)
    string(SUBSTRING "${HEX}" 1 -1 HEX)
    if (NIBBLE STREQUAL "A")
      math(EXPR _res "${_res} + 10")
    elseif (NIBBLE STREQUAL "B")
      math(EXPR _res "${_res} + 11")
    elseif (NIBBLE STREQUAL "C")
      math(EXPR _res "${_res} + 12")
    elseif (NIBBLE STREQUAL "D")
      math(EXPR _res "${_res} + 13")
    elseif (NIBBLE STREQUAL "E")
      math(EXPR _res "${_res} + 14")
    elseif (NIBBLE STREQUAL "F")
      math(EXPR _res "${_res} + 15")
    else()
      math(EXPR _res "${_res} + ${NIBBLE}")
    endif()

    string(LENGTH "${HEX}" _strlen)
  endwhile()

  set(${DEC} ${_res} PARENT_SCOPE)
endfunction()

function(check_version major minor)

    file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/include/iconv.h.in" iconv_version_str
         REGEX "^#[\t ]*define[\t ]+_LIBICONV_VERSION[\t ]+0x([0-9a-fA-F])+.*")
        
    
    string(REGEX MATCH "x([0-9a-fA-F])+"
      VERSION ${iconv_version_str})
    string(REGEX MATCH "([0-9a-fA-F]+)"
      VERSION ${VERSION})
     
    from_hex("${VERSION}" VERSION_DEC)  
    
    math(EXPR MAJOR_VERSION "${VERSION_DEC} / 256")
    math(EXPR MINOR_VERSION "${VERSION_DEC} - ${MAJOR_VERSION} * 256") 
       
    set(${major} ${MAJOR_VERSION} PARENT_SCOPE)
    set(${minor} ${MINOR_VERSION} PARENT_SCOPE)

endfunction(check_version)


function(report_version name ver)

    if(NOT WIN32)
      string(ASCII 27 Esc)
      set(BoldYellow  "${Esc}[1;33m")
      set(ColourReset "${Esc}[m")
    endif()    
        
    message("- ${BoldYellow}${name} version ${ver}${ColourReset}")
    
endfunction()  

