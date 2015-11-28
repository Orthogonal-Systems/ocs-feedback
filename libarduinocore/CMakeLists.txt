cmake_minimum_required(VERSION 2.8)
project (ARDUINO)

include(${CMAKE_SOURCE_DIR}/arduino-uno-crosscompile.cmake)

set (PROJECT_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)
set (PROJECT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
 
file(GLOB ARDUINO_SRCS ${PROJECT_SOURCE_DIR}/*.cpp ${PROJECT_SOURCE_DIR}/*.c)
 
include_directories("${PROJECT_BINARY_DIR}")
include_directories("${PROJECT_INCLUDE_DIR}")
 
add_avr_library(${PROJECT_NAME} STATIC ${ARDUINO_SRCS})
