################################################################################
# boards_txt-reader.cmake:
#   parses arduino style boards.txt file to get implementation specfic variables 
################################################################################

### Variables set
# AVR_MCU         - mcu type, i.e. atmega328p (uno)
# F_CPU           - nominal frequency set in software
# AVR_PROGRAMMER  - programmer protocol, i.e. arduino, arduinoISP, etc ...
# AVR_L_FUSE      - lower fuse byte
# AVR_H_FUSE      - upper fuse byte
# AVR_E_FUSE      - extended fuse byte, not for all devices
# AVR_UPLOAD_BAUD - baudrate for upload

function(parse_boards_txt_file BOARD_NAME EXPRESSION)
  file(STRINGS "${CMAKE_SOURCE_DIR}/tools/boards.txt" teststr REGEX "^${BOARD_NAME}${EXPRESSION}")
  STRING(REGEX MATCH "=([a-zA-Z0-9]+)" teststr ${teststr})
  #STRING(REGEX MATCH "=([\S+])" teststr ${teststr})
  SET(tempstr ${CMAKE_MATCH_1} PARENT_SCOPE)
endfunction(parse_boards_txt_file BOARD_NAME)

function(read_boards_txt_file BOARD_NAME)
  parse_boards_txt_file(${BOARD_NAME} "\.build\.mcu=")
  SET(AVR_MCU ${tempstr} PARENT_SCOPE)
  SET(AVR_MCU_STAT [AUTO] PARENT_SCOPE)

  parse_boards_txt_file(${BOARD_NAME} "\.build\.f_cpu=")
  SET(F_CPU ${tempstr} PARENT_SCOPE)
  SET(F_CPU_STAT [AUTO] PARENT_SCOPE)

  parse_boards_txt_file(${BOARD_NAME} "\.upload\.protocol=")
  SET(AVR_PROGRAMMER ${tempstr} PARENT_SCOPE)
  SET(AVR_PROGRAMMER_STAT [AUTO] PARENT_SCOPE)

  parse_boards_txt_file(${BOARD_NAME} "\.bootloader\.low_fuses=")
  SET(AVR_L_FUSE ${tempstr} PARENT_SCOPE)
  SET(AVR_L_FUSE_STAT [AUTO] PARENT_SCOPE)

  parse_boards_txt_file(${BOARD_NAME} "\.bootloader\.high_fuses=")
  SET(AVR_H_FUSE ${tempstr} PARENT_SCOPE)
  SET(AVR_H_FUSE_STAT [AUTO] PARENT_SCOPE)

  parse_boards_txt_file(${BOARD_NAME} "\.bootloader\.extended_fuses=")
  SET(AVR_E_FUSE ${tempstr} PARENT_SCOPE)
  SET(AVR_E_FUSE_STAT [AUTO] PARENT_SCOPE)

  parse_boards_txt_file(${BOARD_NAME} "\.upload\.speed=")
  SET(AVR_UPLOAD_BAUD ${tempstr} PARENT_SCOPE)
  SET(AVR_UPLOAD_BAUD_STAT [AUTO] PARENT_SCOPE)

endfunction(read_boards_txt_file BOARD_NAME)
