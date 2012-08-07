
# Copyright (c) 2012 Stefan Eilemann <Stefan.Eilemann@epfl.ch>

# write in-source FindPackages.cmake
function(USE_EXTERNAL_DEPS name)
  string(TOUPPER ${name} NAME)
  set(_depsIn "${CMAKE_CURRENT_BINARY_DIR}/${name}FindPackages.cmake")
  set(_depsOut "${${NAME}_SOURCE}/CMake/FindPackages.cmake")
  set(_scriptdir ${CMAKE_CURRENT_BINARY_DIR}/${name})
  set(DEPMODE)

  file(WRITE ${_depsIn} "# generated by Buildyard, do not edit.\n\n")
  foreach(_dep ${${NAME}_DEPENDS})
    if(${_dep} STREQUAL "OPTIONAL")
      set(DEPMODE)
    elseif(${_dep} STREQUAL "REQUIRED")
      set(DEPMODE " REQUIRED")
    else()
      string(TOUPPER ${_dep} _DEP)
      set(COMPONENTS)
      if(${NAME}_${_DEP}_COMPONENTS)
        set(COMPONENTS " COMPONENTS ${${NAME}_${_DEP}_COMPONENTS}")
      endif()
      if(NOT ${_DEP}_SKIPFIND)
        file(APPEND ${_depsIn}
          "find_package(${_dep} ${${_DEP}_VERSION}${DEPMODE}${COMPONENTS})\n"
          "if(${_dep}_FOUND)\n"
          "  set(${_dep}_name ${_dep})\n"
          "elseif(${_DEP}_FOUND)\n"
          "  set(${_dep}_name ${_DEP})\n"
          "endif()\n"
          "if(${_dep}_name)\n"
          "  link_directories(\${\${${_dep}_name}_LIBRARY_DIRS})\n"
          "  include_directories(\${\${${_dep}_name}_INCLUDE_DIRS})\n"
          "endif()\n\n"
          )
      endif()
    endif()
  endforeach()

  file(WRITE ${_scriptdir}/writeDeps.cmake
    "list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/CMake)\n"
    "include(UpdateFile)\n"
    "update_file(${_depsIn} ${_depsOut})")

  ExternalProject_Add_Step(${name} FindPackages
    COMMENT "Updating ${_depsOut}"
    COMMAND ${CMAKE_COMMAND} -DBUILDYARD:PATH=${CMAKE_SOURCE_DIR}
            -P ${_scriptdir}/writeDeps.cmake
    DEPENDEES update patch DEPENDERS configure ALWAYS 1
    )
endfunction()
