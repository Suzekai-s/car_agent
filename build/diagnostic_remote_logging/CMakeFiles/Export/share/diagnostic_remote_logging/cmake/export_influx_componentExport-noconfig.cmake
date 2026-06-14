#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "diagnostic_remote_logging::influx_component" for configuration ""
set_property(TARGET diagnostic_remote_logging::influx_component APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(diagnostic_remote_logging::influx_component PROPERTIES
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libinflux_component.so"
  IMPORTED_SONAME_NOCONFIG "libinflux_component.so"
  )

list(APPEND _IMPORT_CHECK_TARGETS diagnostic_remote_logging::influx_component )
list(APPEND _IMPORT_CHECK_FILES_FOR_diagnostic_remote_logging::influx_component "${_IMPORT_PREFIX}/lib/libinflux_component.so" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
