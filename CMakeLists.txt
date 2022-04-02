cmake_minimum_required (VERSION 3.16.0)
project (MyGame VERSION 2022.1)

# Common dirs for all produced bin artifacts 
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 COMPONENTS Core Quick Multimedia Sql REQUIRED)
qt_add_big_resources(GAME_ASSETS src/scene/scene.qrc src/sound/sound.qrc src/visual/visual.qrc)
set(PROJECT_SOURCES src/main.cpp src/Sandbox.qml  ${GAME_ASSETS} src/qml/qml.qrc)

qt_add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

target_link_libraries(${PROJECT_NAME}
PRIVATE
  Qt::Core
  Qt::Quick
)

add_subdirectory (dep/clayground)
