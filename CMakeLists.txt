cmake_minimum_required(VERSION 3.1)

if (QAK_INTRINSIC)
    message(STATUS "Qak: Intrinsic mode ${QAK_INTRINSIC}")
else()
    set( QAK_lib_type static)
    if (QAK_SHARED)
        set( QAK_lib_type shared)
    endif()
    message(STATUS "Qak: Builing as ${QAK_lib_type} library")
endif()

project(qak VERSION 1.4.1 DESCRIPTION "QML Aid Kit")

# Get the current working branch
execute_process(
  COMMAND git rev-parse --abbrev-ref HEAD
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  OUTPUT_VARIABLE QAK_GIT_BRANCH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Get the latest abbreviated commit hash of the working branch
execute_process(
  COMMAND git log -1 --format=%h
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  OUTPUT_VARIABLE QAK_GIT_COMMIT_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

set( QAK_DEFINITIONS
    "-DQAK_VERSION=\"${QAK_GIT_COMMIT_HASH}\""
    "-DQAK_GIT_VERSION=\"${QAK_GIT_BRANCH}\""
    -DQAK_AUTO_REGISTER
    -DQAK_NO_WARNINGS
    #PARENT_SCOPE
    CACHE STRING "QAK Definitions"
)

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to run moc automatically when needed
set(CMAKE_AUTOMOC ON)
# Create code from a list of Qt designer ui files
#set(CMAKE_AUTOUIC ON)

include_directories(${QtQml_INCLUDE_DIRS})
add_definitions(
    ${QtQml_DEFINITIONS}
    ${Qt5Quick_DEFINITIONS}
    ${Qt5Widgets_DEFINITIONS}
)

add_definitions(${QAK_DEFINITIONS})

set( QAK_PACKAGES
    Core Multimedia Qml Widgets Gui Quick QuickControls2
    CACHE STRING "QAK Packages"
)

find_package(Qt5 COMPONENTS ${QAK_PACKAGES} REQUIRED)

#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror -std=c++11 -fstrict-aliasing -pedantic-errors -pedantic -Wno-deprecated-declarations -Wno-unused-variable")

set( QAK_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/aid_p.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/maskedmousearea.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/resource.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/store.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/propertytoggle.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/mouserotate_p.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/itemanimation_p.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/shutdowncheck.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/env_p.cpp
    CACHE STRING "QAK Sources"
)
include_directories(src)

include_directories(.)
list(APPEND QAK_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/qak.cpp")

set( QAK_RESOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/qak.qrc
    CACHE STRING "QAK Recources"
)
qt5_add_resources( QT_RESOURCES ${QAK_RESOURCES} )

set( QAK_LIBS
    Qt5::Core
    Qt5::Multimedia
    Qt5::Quick
    Qt5::Gui
    Qt5::Widgets
    Qt5::QuickControls2
    CACHE STRING "QAK Libs"
)
#MESSAGE(${QT_INCLUDES})
#if (NOT QAK_INTRINSIC)
if (QAK_SHARED)
    add_library(qak SHARED ${QAK_SOURCES} ${QT_RESOURCES} ${QT_INCLUDES} )
else()
    add_library(qak STATIC ${QAK_SOURCES} ${QT_RESOURCES} ${QT_INCLUDES} )
endif()

target_link_libraries(qak ${QAK_LIBS} )
set_target_properties(qak PROPERTIES PUBLIC_HEADER qak.h)
target_include_directories(qak PRIVATE src)

target_compile_options(qak PRIVATE -Wall -Werror -std=c++11 -fstrict-aliasing -pedantic-errors -pedantic -Wno-deprecated-declarations -Wno-unused-variable)
target_compile_features(qak PRIVATE cxx_std_11)


include(GNUInstallDirs)
install(
    TARGETS qak
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
