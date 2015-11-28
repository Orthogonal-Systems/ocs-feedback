cmake_minimum_required(VERSION 2.8)
project (SD)
 
include(${CMAKE_SOURCE_DIR}/arduino-uno-crosscompile.cmake)

set (PROJECT_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)
set (PROJECT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
 
file(GLOB SD_SRCS ${PROJECT_SOURCE_DIR}/*.cpp ${PROJECT_SOURCE_DIR}/*.c)
 
### need to include if arduino based library
include_directories(${CMAKE_SOURCE_DIR}/libarduinocore)
LINK_DIRECTORIES(${CMAKE_SOURCE_DIR}/libarduinocore)

link_libraries(ARDUINO)
###

include_directories("${PROJECT_BINARY_DIR}")
include_directories("${PROJECT_INCLUDE_DIR}")
 
add_avr_library(${PROJECT_NAME} STATIC ${SD_SRCS})
