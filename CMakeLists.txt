cmake_minimum_required(VERSION 2.8)
project (ocs-base)
 
set(CMAKE_BINARY_DIR ${CMAKE_SOURCE_DIR}/build)
 
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR})
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR})
 
set(PROJECT_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)

include_directories("${PROJECT_INCLUDE_DIR}")
include_directories("${PROJECT_SOURCE_DIR}")
 
### Main Arduino library that must be included if any arduino library is used
add_subdirectory(libarduinocore) 
### Standard Arduino 1.0.5 libraries
add_subdirectory(EEPROM)          # EEPROM
#add_subdirectory(Esplora)        # esplora is not supported
add_subdirectory(Ethernet)        # Ethernet Library
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

### User Projects and Libraries
add_subdirectory(amc7812)         # TI AMC7812 ADC & DAC
add_subdirectory(usart)           # simple serial communication, without arduino
