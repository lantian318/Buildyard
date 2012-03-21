if(MSVC) # Can't autopain on Windows without too much hassle
  return()
endif()
if(APPLE)
  set(AUTORECONF /opt/local/bin/autoreconf)
else()
  set(AUTORECONF autoreconf)
endif()

set(HWLOC_VERSION 1.4.0)
set(HWLOC_REPO_URL http://svn.open-mpi.org/svn/hwloc/tags/hwloc-1.4.0/)
set(HWLOC_REPO_TYPE SVN)
set(HWLOC_SOURCE "${CMAKE_SOURCE_DIR}/src/hwloc")
set(HWLOC_EXTRA
  PATCH_COMMAND cd ${HWLOC_SOURCE} && env ${AUTORECONF} -i
  CONFIGURE_COMMAND ${HWLOC_SOURCE}/configure  "--prefix=${CMAKE_CURRENT_BINARY_DIR}/install"
)
