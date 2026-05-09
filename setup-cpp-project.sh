#!/bin/bash
#####################################################
echo "This script is for setting up a C++ project with CMake and Google Test."
echo "It will create a basic directory structure and CMakeLists.txt files for you."
#####################################################


#####################################################
# Install System Dependencies

# Check if CMake exists, if not prompt the install
echo "Checking system for dependencies..."
echo
if ! command -v cmake &> /dev/null; then
    echo "WARNING: CMake is not installed. It is a required part of this script."
    read -p "Would you like to proceed? (y/n): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        sudo apt install cmake
    else
        echo "CMake will not be installed."
        echo "Aborting script..."
        exit 1
    fi
else
    echo "SUCCESS: CMake is installed on this system."
fi

# Check if Git exists, if not prompt the install
if ! command -v git &> /dev/null; then
    echo "WARNING: Git is not installed. It is a required part of this script."
    read -p "Would you like to proceed? (y/n): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        sudo apt install git
    else
        echo "Git will not be installed."
        echo "Aborting script..."
        exit 1
    fi
else
    echo "SUCCESS: Git is installed on this system."
fi

# Check if C++ compiler, if not prompt installation
if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
    echo "WARNING: No C++ compiler installed. This is necessary for CMake to compile your project."
    read -p "Would you like to install one? (y/n): " choice
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
else
    echo "SUCCESS: A C++ compiler is installed on this system."
fi
#####################################################


#####################################################
# Create the project directory structure
read -p "Enter the project name: " project_name
echo -n "Building directory structure in dir $project_name..."
mkdir -p $project_name/src
mkdir -p $project_name/include
mkdir -p $project_name/tests
mkdir -p $project_name/build
echo "Done"
#####################################################


#####################################################
# Create placeholder .cpp files
echo -n "Creating sample .cpp files..."
cat > $project_name/src/main.cpp << EOF
// THIS IS EXAMPLE CODE - YOU CAN SAFELY DELETE THE FILE CONTENTS
#include <iostream>

int main() {
    std::cout << "Hello World!\n";
}
EOF

cat > $project_name/src/main_lib.cpp << EOF
// THIS IS EXAMPLE CODE - YOU CAN SAFELY DELETE THE FILE CONTENTS
#include <string>

std::string create_hello_world() {
    return "Hello, World!\n";
}
EOF

cat > $project_name/include/main_lib.h << EOF
// THIS IS EXAMPLE CODE - YOU CAN SAFELY DELETE THE FILE CONTENTS
std::string create_hello_world();
EOF

cat > $project_name/tests/main_lib_test.cpp << EOF
// THIS IS EXAMPLE CODE - YOU CAN SAFELY DELETE THE FILE CONTENTS
#include <gtest/gtest.h>
#include <main_lib.h>

TEST(HelloWorldTest, String) {
    EXPECT_EQ(create_hello_world(), "Hello, World!\n");
}
EOF
echo "Done"
#####################################################


#####################################################
# Create the root CMakeLists.txt file for the project
echo -n "Creating project root CMakeLists.txt file..."
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
echo "Done"
#####################################################


#####################################################
# Create a CMakeLists.txt file for the src directory
echo -n "Creating project/src CMakeList.txt file..."
cat > $project_name/src/CMakeLists.txt << EOF
add_library(main_lib main_lib.cpp)
add_executable(\${PROJECT_NAME} main.cpp)
target_include_directories(main_lib PUBLIC ../include)
target_link_libraries(\${PROJECT_NAME} PRIVATE main_lib)
EOF
echo "Done"
#####################################################


#####################################################
# Create a CMakeLists.txt file for the tests directory
echo -n "Creating project/tests CMakeList.txt file..."
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
echo "Done"
#####################################################


#####################################################
# Clean up messages
echo "Script has completed setup for $project_name in your current working directory"
echo "You can now find the template project in $PWD/$project_name/"
echo "You can build the template project running cd $project_name/build && cmake .. && cmake --build ."
read -p "Press enter to exit..."
#####################################################