cmake_minimum_required(VERSION 3.2)
project (ocs-base)
 
################################################################################
# define custom toolchain and mcu here
################################################################################
SET(AVR_UPLOADTOOL avrdude)
SET(AVR_PROGRAMMER arduino)
SET(AVR_UPLOADTOOL_PORT /dev/ttyACM*)
# MCU and fuses
SET(AVR_MCU atmega328p)
SET(F_CPU "16000000L")  # Hz
SET(H_FUSE 0xff)
SET(L_FUSE 0xde)
SET(E_FUSE 0x05) # for arduino bootloader only I think


################################################################################
# status messages
################################################################################
message(STATUS "Current C compiler is: ${CMAKE_C_COMPILER}")
message(STATUS "Current CXX compiler is: ${CMAKE_CXX_COMPILER}")
message(STATUS "Current programmer is: ${AVR_PROGRAMMER}")
message(STATUS "Current uploadtool is: ${AVR_UPLOADTOOL}")
message(STATUS "Current programmer is: ${AVR_PROGRAMMER}")
message(STATUS "Current upload port is: ${AVR_UPLOADTOOL_PORT}")
message(STATUS "Current uploadtool options are: ${AVR_UPLOADTOOL_OPTIONS}")
message(STATUS "Current MCU is set to: ${AVR_MCU}")
message(STATUS "Current H_FUSE is set to: ${AVR_H_FUSE}")
message(STATUS "Current L_FUSE is set to: ${AVR_L_FUSE}")
message(STATUS "Current E_FUSE is set to: ${AVR_E_FUSE}")

################################################################################
# set build type, don't clobber, default is Release due to timing stuff
# choices: Release, RelWithDebInfo, Debug, MiniSizeRel
################################################################################
IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Release)
ENDIF(NOT CMAKE_BUILD_TYPE)

##################################################################################
# some cmake cross-compile necessities
##################################################################################
if(DEFINED ENV{AVR_FIND_ROOT_PATH})
    set(CMAKE_FIND_ROOT_PATH $ENV{AVR_FIND_ROOT_PATH})
else(DEFINED ENV{AVR_FIND_ROOT_PATH})
    if(EXISTS "/opt/local/avr")
      set(CMAKE_FIND_ROOT_PATH "/opt/local/avr")
    elseif(EXISTS "/usr/avr")
      set(CMAKE_FIND_ROOT_PATH "/usr/avr")
    elseif(EXISTS "/usr/lib/avr")
      set(CMAKE_FIND_ROOT_PATH "/usr/lib/avr")
    else(EXISTS "/opt/local/avr")
      message(FATAL_ERROR "Please set AVR_FIND_ROOT_PATH in your environment.")
    endif(EXISTS "/opt/local/avr")
endif(DEFINED ENV{AVR_FIND_ROOT_PATH})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
# not added automatically, since CMAKE_SYSTEM_NAME is "generic"
set(CMAKE_SYSTEM_INCLUDE_PATH "${CMAKE_FIND_ROOT_PATH}/include")
set(CMAKE_SYSTEM_LIBRARY_PATH "${CMAKE_FIND_ROOT_PATH}/lib")

##################################################################################
# status messages for generating
##################################################################################
message(STATUS "Set CMAKE_FIND_ROOT_PATH to ${CMAKE_FIND_ROOT_PATH}")
message(STATUS "Set CMAKE_SYSTEM_INCLUDE_PATH to ${CMAKE_SYSTEM_INCLUDE_PATH}")
message(STATUS "Set CMAKE_SYSTEM_LIBRARY_PATH to ${CMAKE_SYSTEM_LIBRARY_PATH}")

##################################################################################
# set compiler options for build types
##################################################################################
if(CMAKE_BUILD_TYPE MATCHES Release)
   set(CMAKE_C_FLAGS_RELEASE "-Os")
   set(CMAKE_CXX_FLAGS_RELEASE "-Os")
endif(CMAKE_BUILD_TYPE MATCHES Release)

if(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
   set(CMAKE_C_FLAGS_RELWITHDEBINFO "-Os -save-temps -g -gdwarf-3 -gstrict-dwarf")
   set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-Os -save-temps -g -gdwarf-3 -gstrict-dwarf")
endif(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)

if(CMAKE_BUILD_TYPE MATCHES Debug)
   set(CMAKE_C_FLAGS_DEBUG "-O0 -save-temps -g -gdwarf-3 -gstrict-dwarf")
   set(CMAKE_CXX_FLAGS_DEBUG "-O0 -save-temps -g -gdwarf-3 -gstrict-dwarf")
endif(CMAKE_BUILD_TYPE MATCHES Debug)

##################################################################################
# compiler options for all build types
##################################################################################
add_definitions("-DF_CPU=${F_CPU}")
#add_definitions("-fpack-struct")
add_definitions("-fshort-enums")
add_definitions("-Wall")
#add_definitions("-Werror") # treat warnings as errors
# http://gcc.gnu.org/onlinedocs/gcc-4.8.2/gcc/Alternate-Keywords.html#Alternate-Keywords
# [...]-pedantic and other options cause warnings for many GNU C extensions. You can prevent such warnings within
# one expression by writing __extension__ before the expression. __extension__ has no effect aside from this.[...] 
#add_definitions("-pedantic")
#add_definitions("-pedantic-errors")
#add_definitions("-funsigned-char")
#add_definitions("-funsigned-bitfields")
#add_definitions("-ffunction-sections")
add_definitions("-c")
#add_definitions("-std=gnu99")
SET(CMAKE_C_STANDARD 99)
SET(CMAKE_CXX_STANDARD 11)
add_definitions(-DARDUINO=${ARDUINO_VERSION})
#SET(COPT "-Os")
##SET(CINCS "-I${ArduinoCode_SOURCE_DIR}/libarduinocore")
#add_definitions("-gstabs")
#add_definitions("-mmcu=${MCU}")
#add_definitions(-DF_CPU=${F_CPU})
#add_definitions("-Wall -Wstrict-prototypes")

##################################################################################
# stuff specific to this project
##################################################################################
set(CMAKE_BINARY_DIR ${CMAKE_SOURCE_DIR}/build)
 
#set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})
 
set(PROJECT_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)

include_directories("${PROJECT_INCLUDE_DIR}")
include_directories("${PROJECT_SOURCE_DIR}")
 
### Main Arduino library that must be included if any arduino library is used
add_subdirectory(libarduinocore) 
### Standard Arduino 1.0.5 libraries
add_subdirectory(EEPROM)          # EEPROM
#add_subdirectory(Esplora)        # esplora is not supported
#add_subdirectory(Ethernet)        # Ethernet Library
#add_subdirectory(Firmata)        # Firmata is not supported  
add_subdirectory(GSM)             # library for the GSM shield
add_subdirectory(LiquidCrystal)   # library for most text based LCDs
add_subdirectory(SD)              # library for sd cards
add_subdirectory(Servo)           # library for servo motor control
add_subdirectory(SoftwareSerial)  # bit-banged serial communication
add_subdirectory(SPI)             # SPI communication library
add_subdirectory(Stepper)         # library for stepper motor control
#add_subdirectory(TFT)             # library for TFT LCD screen is not supported right now
add_subdirectory(WiFi)            # library for wifi sheild
add_subdirectory(Wire)            # I2C/TWI communication

##################################################################################
### User Projects and Libraries
###################################################################################

### AMC7812 Chip Driver
add_subdirectory(amc7812)         # TI AMC7812 ADC & DAC
add_subdirectory(usart)           # simple serial communication, without arduino

### add example executable directories, but dont automatically compile it
### to compile: cd build ; make amc7812_[example name]
add_subdirectory(amc7812/examples EXCLUDE_FROM_ALL)
