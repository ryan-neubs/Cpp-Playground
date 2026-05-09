#!/bin/bash
#####################################################
echo "This script is for setting up a C++ project with CMake and Google Test."
echo "It will create a basic directory structure and CMakeLists.txt files for you."
#####################################################


#####################################################
# Install System Dependencies

# Check if CMake exists, if not prompt the install
if ! command -v cmake &> /dev/null; then
    echo "WARNING: CMake is not installed. It is a required part of this script."
    read -p "Would you like to proceed? (y/n)" choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        sudo apt install cmake
    else
        echo "CMake will not be installed."
        echo "Aborting script..."
        exit 1
    fi
fi

# Check if Git exists, if not prompt the install
if ! command -v git &> /dev/null; then
    echo "WARNING: Git is not installed. It is a required part of this script."
    read -p "Would you like to proceed? (y/n)" choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        sudo apt install git
    else
        echo "Git will not be installed."
        echo "Aborting script..."
        exit 1
    fi
fi

# Check if C++ compiler, if not prompt installation
if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
    echo "WARNING: No C++ compiler installed. This is necessary for CMake to compile your project."
    read -p "Would you like to install one? (y/n)" choice
    echo
    if [[ $choice =~ ^[Yy]$ ]]; then
        PS3="Which compiler would you like to install: "
        options=("clang++" "g++" "Cancel")

        select opt in "${options[@]}"
        do
            case $opt in
                "clang++")
                    echo "Installing clang++..."
                    sudo apt install clang++
                    ;;
                "g++")
                    echo "Installing g++..."
                    sudo apt install g++
                    ;;
                "Cancel")
                    echo "WARNING: Cancelling install and continuing with out a C++ compiler. You will need to configure one later."
                    break
                    ;;
                *)
                    echo "Invalid choice selected. Try again."
                    ;;
            esac 
        done
    else
        echo "WARNING: Continuing without C++ compiler, you will need to configure one later."
    fi
fi
#####################################################


#####################################################
# Create the project directory structure
read -p "Enter the project name: " project_name
mkdir -p $project_name/src
mkdir -p $project_name/include
mkdir -p $project_name/tests
mkdir -p $project_name/build
#####################################################


#####################################################
# Create placeholder .cpp files
cat > $project_name/src/main.cpp << EOF
#include <iostream>

int main() {
    std::cout << "Hello World!\n";
}
EOF

cat > $project_name/src/main_lib.cpp << EOF
#include <string>

std::string create_hello_world() {
    return "Hello, World!\n";
}
EOF

cat > $project_name/include/main_lib.h << EOF
std::string create_hello_world();
EOF

cat > $project_name/tests/main_lib_test.cpp << EOF
#include <gtest/gtest.h>
#include <main_lib.h>

TEST(HelloWorldTest, String) {
    EXPECT_EQ(create_hello_world(), "Hello, World!\n");
}
EOF
#####################################################


#####################################################
# Create the root CMakeLists.txt file for the project
cat > $project_name/CMakeLists.txt << EOF
cmake_minimum_required(VERSION 3.10)
project($project_name)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

# Enable CTest
enable_testing()

# Add the source files
include_directories(include)
add_subdirectory(src)
add_subdirectory(tests)
EOF
#####################################################


#####################################################
# Create a CMakeLists.txt file for the src directory
cat > $project_name/src/CMakeLists.txt << EOF
add_library(main_lib main_lib.cpp)
add_executable(\${PROJECT_NAME} main.cpp)
target_include_directories(main_lib PUBLIC ../include)
target_link_libraries(\${PROJECT_NAME} PRIVATE main_lib)
EOF
#####################################################


#####################################################
# Create a CMakeLists.txt file for the tests directory
cat > $project_name/tests/CMakeLists.txt << EOF
include(FetchContent)

# Acquire GTest dependencies
FetchContent_Declare(
googletest 
GIT_REPOSITORY https://github.com/google/googletest.git
GIT_TAG v1.17.0 
)
FetchContent_MakeAvailable(googletest)
include(GoogleTest)

# Create test executables for test files
file(GLOB TEST_SOURCES CONFIGURE_DEPENDS "*_test.cpp")
add_executable(\${PROJECT_NAME}_unit_test \${TEST_SOURCES})
target_link_libraries(\${PROJECT_NAME}_unit_test PUBLIC main_lib)
target_link_libraries(\${PROJECT_NAME}_unit_test PUBLIC GTest::gtest_main)
gtest_discover_tests(\${PROJECT_NAME}_unit_test)

EOF
#####################################################