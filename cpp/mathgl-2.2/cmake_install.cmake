# Install script for directory: /Users/azuri/stella/cpp/mathgl-2.2

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

if(NOT CMAKE_INSTALL_COMPONENT OR "${CMAKE_INSTALL_COMPONENT}" STREQUAL "Unspecified")
  list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
   "/usr/local/share/mathgl/fonts/")
  if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
  if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
    message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
  endif()
file(INSTALL DESTINATION "/usr/local/share/mathgl/fonts" TYPE DIRECTORY FILES "/Users/azuri/stella/cpp/mathgl-2.2/fonts/" REGEX "/\\.svn$" EXCLUDE REGEX "/[^/]*\\.vfm$")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/azuri/stella/cpp/mathgl-2.2/src/cmake_install.cmake")
  include("/Users/azuri/stella/cpp/mathgl-2.2/widgets/cmake_install.cmake")
  include("/Users/azuri/stella/cpp/mathgl-2.2/include/cmake_install.cmake")
  include("/Users/azuri/stella/cpp/mathgl-2.2/udav/cmake_install.cmake")
  include("/Users/azuri/stella/cpp/mathgl-2.2/json/cmake_install.cmake")
  include("/Users/azuri/stella/cpp/mathgl-2.2/lang/cmake_install.cmake")
  include("/Users/azuri/stella/cpp/mathgl-2.2/utils/cmake_install.cmake")
  include("/Users/azuri/stella/cpp/mathgl-2.2/examples/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

file(WRITE "/Users/azuri/stella/cpp/mathgl-2.2/${CMAKE_INSTALL_MANIFEST}" "")
foreach(file ${CMAKE_INSTALL_MANIFEST_FILES})
  file(APPEND "/Users/azuri/stella/cpp/mathgl-2.2/${CMAKE_INSTALL_MANIFEST}" "${file}\n")
endforeach()