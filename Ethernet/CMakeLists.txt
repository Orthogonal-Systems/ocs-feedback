cmake_minimum_required(VERSION 2.8)
project (ETHERNET)
 
include(${CMAKE_SOURCE_DIR}/arduino-uno-crosscompile.cmake)

set (PROJECT_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)# ${PROJECT_SOURCE_DIR}/utility)
set (PROJECT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src ${CMAKE_CURRENT_SOURCE_DIR}/utility)
 
file(GLOB ETHERNET_SRCS ${PROJECT_SOURCE_DIR}/*.cpp ${PROJECT_SOURCE_DIR}/*.c)
 
### need to include if arduino based library
include_directories(${CMAKE_SOURCE_DIR}/libarduinocore)
LINK_DIRECTORIES(${CMAKE_SOURCE_DIR}/libarduinocore)

link_libraries(ARDUINO)
###

include_directories("${PROJECT_BINARY_DIR}")
include_directories("${PROJECT_INCLUDE_DIR}")
 
add_library(${PROJECT_NAME} STATIC ${ETHERNET_SRCS})
