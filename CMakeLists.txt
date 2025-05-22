cmake_minimum_required(VERSION 3.15)
project(3DRenderer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include_directories(libs)

# Update to match C++ source files
file(GLOB_RECURSE sources src/*.cpp)

message(STATUS "Sources: ${sources}")

find_package(SDL2 REQUIRED)

if (APPLE)
  include_directories(/opt/homebrew/include)
  link_directories(/opt/homebrew/lib/)
endif ()

add_executable(${PROJECT_NAME} ${sources})

target_link_libraries(${PROJECT_NAME} SDL2 SDL2_image SDL2_mixer SDL2_ttf)
target_compile_options(${PROJECT_NAME} PRIVATE -Wall)
