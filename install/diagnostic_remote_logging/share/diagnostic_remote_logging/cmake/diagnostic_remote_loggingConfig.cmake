# generated from ament/cmake/core/templates/nameConfig.cmake.in

# prevent multiple inclusion
if(_diagnostic_remote_logging_CONFIG_INCLUDED)
  # ensure to keep the found flag the same
  if(NOT DEFINED diagnostic_remote_logging_FOUND)
    # explicitly set it to FALSE, otherwise CMake will set it to TRUE
    set(diagnostic_remote_logging_FOUND FALSE)
  elseif(NOT diagnostic_remote_logging_FOUND)
    # use separate condition to avoid uninitialized variable warning
    set(diagnostic_remote_logging_FOUND FALSE)
  endif()
  return()
endif()
set(_diagnostic_remote_logging_CONFIG_INCLUDED TRUE)

# output package information
if(NOT diagnostic_remote_logging_FIND_QUIETLY)
  message(STATUS "Found diagnostic_remote_logging: 4.0.7 (${diagnostic_remote_logging_DIR})")
endif()

# warn when using a deprecated package
if(NOT "" STREQUAL "")
  set(_msg "Package 'diagnostic_remote_logging' is deprecated")
  # append custom deprecation text if available
  if(NOT "" STREQUAL "TRUE")
    set(_msg "${_msg} ()")
  endif()
  # optionally quiet the deprecation message
  if(NOT ${diagnostic_remote_logging_DEPRECATED_QUIET})
    message(DEPRECATION "${_msg}")
  endif()
endif()

# flag package as ament-based to distinguish it after being find_package()-ed
set(diagnostic_remote_logging_FOUND_AMENT_PACKAGE TRUE)

# include all config extra files
set(_extras "ament_cmake_export_dependencies-extras.cmake;ament_cmake_export_targets-extras.cmake")
foreach(_extra ${_extras})
  include("${diagnostic_remote_logging_DIR}/${_extra}")
endforeach()
