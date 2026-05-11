#!/bin/bash
source ./log-formatter.sh
#####################################################
echo "====================================================================================================================="
echo "C++ Project Setup Script"
echo "====================================================================================================================="
echo "This script is for setting up a C++ project with CMake and Google Test."
echo "It will create a basic directory structure and CMakeLists.txt files for you."
echo "It will also check for CMake, Git, and a C++ compiler and prompt you to install them if they are not found."
echo "This script is intended for use on Linux systems with apt package manager."
echo "====================================================================================================================="
#####################################################

echo
echo
echo
prompt_input "Press enter to begin..."
echo
echo
echo

#####################################################
# Install System Dependencies

# Check if CMake exists, if not prompt the install
echo "====================================================================================================================="
log_info "Checking system for dependencies..."
echo
if ! command -v cmake &> /dev/null; then
    log_warning "CMake is not installed. It is a required part of this script."
    prompt_input "Would you like to install CMake? (y/n): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        sudo apt install cmake -y
    else
        log_warning "CMake will not be installed."
        log_alert "Aborting script..."
        exit 1
    fi
else
    log_success "CMake is installed on this system."
fi

# Check if Git exists, if not prompt the install
if ! command -v git &> /dev/null; then
    log_warning "Git is not installed. It is a required part of this script."
    prompt_input "Would you like to install Git? (y/n): " choice
    if [[ $choice =~ ^[Yy]$ ]]; then
        sudo apt install git -y
    else
        log_warning "Git will not be installed."
        log_alert "Aborting script..."
        exit 1
    fi
else
    log_success "Git is installed on this system."
fi

# Check if C++ compiler, if not prompt installation
if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
    log_warning "No C++ compiler installed. This is necessary for CMake to compile your project."
    prompt_input "Would you like to install one? (y/n): " choice
    echo
    if [[ $choice =~ ^[Yy]$ ]]; then
        PS3=$'\033[1;36m[INPUT]:\033[0m ''Which compiler would you like to install: '
        options=("clang++" "g++" "Cancel")

        select opt in "${options[@]}"
        do
            case $opt in
                "clang++")
                    log_info "Installing clang++..."
                    sudo apt install clang++ -y
                    break
                    ;;
                "g++")
                    log_info "Installing g++..."
                    sudo apt install g++ -y
                    break
                    ;;
                "Cancel")
                    log_warning "Cancelling install and continuing without a C++ compiler. You will need to configure one later."
                    break
                    ;;
                *)
                    log_warning "Invalid choice selected. Try again."
                    ;;
            esac 
        done
    else
        log_warning "Continuing without C++ compiler, you will need to configure one later."
    fi
else
    log_success "A C++ compiler is installed on this system."
fi

echo
log_info "All dependencies have been checked. Continuing with project setup..."
echo "====================================================================================================================="
#####################################################

echo

#####################################################
# Create the project directory structure
echo "====================================================================================================================="
prompt_input "Enter the project name: " project_name
echo
log_task_begin "Building directory structure in dir $project_name..."
mkdir -p $project_name/src
mkdir -p $project_name/include
mkdir -p $project_name/tests
mkdir -p $project_name/build
log_task_end
#####################################################

echo

#####################################################
# Create placeholder .cpp files
log_task_begin "Creating sample .cpp files..."
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
log_task_end
#####################################################

echo

#####################################################
# Create the root CMakeLists.txt file for the project
log_task_begin "Creating project root CMakeLists.txt file..."
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
log_task_end
#####################################################

echo

#####################################################
# Create a CMakeLists.txt file for the src directory
log_task_begin "Creating project/src CMakeList.txt file..."
cat > $project_name/src/CMakeLists.txt << EOF
add_library(main_lib main_lib.cpp)
add_executable(\${PROJECT_NAME} main.cpp)
target_include_directories(main_lib PUBLIC ../include)
target_link_libraries(\${PROJECT_NAME} PRIVATE main_lib)
EOF
log_task_end
#####################################################

echo

#####################################################
# Create a CMakeLists.txt file for the tests directory
log_task_begin "Creating project/tests CMakeList.txt file..."
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
log_task_end
echo "====================================================================================================================="
#####################################################

echo

#####################################################
# Clean up messages
echo "====================================================================================================================="
log_info "Script has completed setup for $project_name in your current working directory"
echo
log_info "You can now find the template project in $PWD/$project_name/"
log_info "You can build the template project running cd $project_name/build && cmake .. && cmake --build ."
log_info "You can run the tests with cd $project_name/build && ctest"
log_info "You can delete the example .cpp files and CMakeLists.txt files and replace them with your own code, but they are there to help you get started quickly."
log_info "If you have any questions or need help, please reach out to me on GitHub."
log_info "Thanks for using this script, I hope it helps you get started with C++ development!"
echo "====================================================================================================================="
echo
echo
echo
prompt_input "Press enter to exit..."
#####################################################
