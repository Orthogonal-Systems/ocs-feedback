cmake_minimum_required(VERSION 2.8)
project (blink)

include(${ARDUINO_SETTINGS_FILE})
 
set(PROJECT_INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include)
 
include_directories("${PROJECT_BINARY_DIR}")
include_directories("${PROJECT_INCLUDE_DIR}")

### add example executable directories
add_avr_executable(blink-avr src/blink-avr.c)
add_avr_executable(blink-arduino src/blink-arduino.cpp)
### add the dependant libraries
avr_target_link_libraries(blink-arduino ARDUINO)
