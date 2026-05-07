#!/bin/bash
echo "This script is for setting up a C++ project with CMake and Google Test."
echo "It will create a basic directory structure and CMakeLists.txt files for you."

# Create the project directory structure
read -p "Enter the project name: " project_name
mkdir -p $project_name/src
mkdir -p $project_name/include
mkdir -p $project_name/tests
mkdir -p $project_name/build

# Create a basic CMakeLists.txt file for the project
cat > $project_name/CMakeLists.txt << EOF
cmake_minimum_required(VERSION 3.10)
project($project_name)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# Add the source files
include_directories(include)
add_subdirectory(src)
add_subdirectory(tests)

EOF

# Create a CMakeLists.txt file for the src directory
cat > $project_name/src/CMakeLists.txt << EOF
add_library(main_lib main_lib.cpp)
add_executable(${PROJECT_NAME} main.cpp)
target_include_directories(main_lib PUBLIC ../include)
target_link_libraries(${PROJECT_NAME} PRIVATE main_lib)
EOF

# Create a CMakeLists.txt file for the tests directory
cat > $project_name/tests/CMakeLists.txt << EOF
FetchContent_Declare(
googletest 
GIT_REPOSITORY https://github.com/google/googletest.git
GIT_TAG v1.17.0 
)


EOF
