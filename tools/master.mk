########################################################################
#
# Makefile for compiling Arduino sketches from command line
# System part (i.e. project independent)
#
# Copyright (C) 2015 Matt Ebert <http://mebert.org>, based on
# Sudar's work: <http://sudarmuthu.com>
#
# Copyright (C) 2012 Sudar <http://sudarmuthu.com>, based on
# M J Oldfield work: https://github.com/mjoldfield/Arduino-Makefile
#
# Copyright (C) 2010,2011,2012 Martin Oldfield <m@mjo.tc>, based on
# work that is copyright Nicholas Zambetti, David A. Mellis & Hernando
# Barragan.
#
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
#
# Adapted from Arduino-Makefile by Sudar
#
# Adapted from Arduino 0011 Makefile by M J Oldfield
#
# Original Arduino adaptation by mellis, eighthave, oli.keller
#
# Current version: 1.5
#
# Refer to HISTORY.md file for complete history of changes
#
########################################################################
#
# The default configuation uses the libraries that ship with the 1.0.5 
# version of the Arduino application, encapsulated into the project as
# standalone libraries.
#
# To use as I intend the Arduino library references will be internal to
# the project, otherwise you can use the Arduino-Makefile as Sudar
# intended with the Arduino application on the system.
#
# -- Matt Ebert
#
########################################################################
#
# PATHS YOU NEED TO SET UP
#
#
# We need to worry about three different sorts of file:
#
# 1. The directory where the *.mk files are stored
#    => ARDMK_DIR
#
# 2. Things which are always in the Arduino distribution e.g.
#    boards.txt, libraries, &c.
#    => ARDUINO_DIR
#
# 3. Things which might be bundled with the Arduino distribution, but
#    might come from the system. Most of the toolchain is like this:
#    on Linux it's supplied by the system.
#    => AVR_TOOLS_DIR
#
# Having set these three variables, we can work out the rest assuming
# that things are canonically arranged beneath the directories defined
# above.
#
# On the Mac with IDE 1.0 you might want to set:
#
#   ARDUINO_DIR   = /Applications/Arduino.app/Contents/Resources/Java
#   ARDMK_DIR     = /usr/local
#
# On the Mac with IDE 1.5+ you might want to set:
#
#   ARDUINO_DIR   = /Applications/Arduino.app/Contents/Java
#   ARDMK_DIR     = /usr/local
#
# On Linux, you might prefer:
#
#   ARDUINO_DIR   = /usr/share/arduino
#   ARDMK_DIR     = /usr/share/arduino
#   AVR_TOOLS_DIR = /usr
#
# On Windows declare this environmental variables using the windows
# configuration options. Control Panel > System > Advanced system settings
# Also take into account that when you set them you have to add '\' on
# all spaces and special characters.
# ARDUINO_DIR and AVR_TOOLS_DIR have to be relative and not absolute.
# This are just examples, you have to adapt this variables accordingly to
# your system.
#
#   ARDUINO_DIR   =../../../../../Arduino
#   AVR_TOOLS_DIR =../../../../../Arduino/hardware/tools/avr
#   ARDMK_DIR     = /cygdrive/c/Users/"YourUser"/Arduino-Makefile
#
# On Windows it is highly recommended that you create a symbolic link directory
# for avoiding using the normal directories name of windows such as
# c:\Program Files (x86)\Arduino
# For this use the command mklink on the console.
#
#
# You can either set these up in the Makefile, or put them in your
# environment e.g. in your .bashrc
#
# If you don't specify these, we can try to guess, but that might not work
# or work the way you want it to.
#
# If you'd rather not see the configuration output, define ARDUINO_QUIET.
#
########################################################################
#
# DEPENDENCIES
#
# The Perl programs need a couple of libraries:
#    Device::SerialPort
#
########################################################################
#
# STANDARD ARDUINO WORKFLOW
#
# Given a normal sketch directory, all you need to do is to create
# a small Makefile which defines a few things, and then includes this one.
#
# For example:
#
#       ARDUINO_LIBS = Ethernet SPI
#       BOARD_TAG    = uno
#       MONITOR_PORT = /dev/cu.usb*
#
#       include /usr/share/arduino/Arduino.mk
#
# Hopefully these will be self-explanatory but in case they're not:
#
#    ARDUINO_LIBS - A list of any libraries used by the sketch (we
#                   assume these are in $(ARDUINO_DIR)/hardware/libraries
#                   or your sketchbook's libraries directory)
#
#    BOARD_TAG    - The tag for the board e.g. uno or mega
#                   'make show_boards' shows a list
#
#    MONITOR_PORT - The port where the Arduino can be found (only needed
#                   when uploading)
#
# If you have your additional libraries relative to your source, rather
# than in your "sketchbook", also set USER_LIB_PATH, like this example:
#
#        USER_LIB_PATH := $(realpath ../../libraries)
#
# If you've added the Arduino-Makefile repository to your git repo as a
# submodule (or other similar arrangement), you might have lines like this
# in your Makefile:
#
#        ARDMK_DIR := $(realpath ../../tools/Arduino-Makefile)
#        include $(ARDMK_DIR)/Arduino.mk
#
# In any case, once this file has been created the typical workflow is just
#
#   $ make upload
#
# All of the object files are created in the build-{BOARD_TAG} subdirectory
# All sources should be in the current directory and can include:
#  - at most one .pde or .ino file which will be treated as C++ after
#    the standard Arduino header and footer have been affixed.
#  - any number of .c, .cpp, .s and .h files
#
# Included libraries are built in the build-{BOARD_TAG}/libs subdirectory.
#
# Besides make upload, there are a couple of other targets that are available.
# Do make help to get the complete list of targets and their description
#
########################################################################
#
# SERIAL MONITOR
#
# The serial monitor just invokes the GNU screen program with suitable
# options. For more information see screen (1) and search for
# 'character special device'.
#
# The really useful thing to know is that ^A-k gets you out!
#
# The fairly useful thing to know is that you can bind another key to
# escape too, by creating $HOME{.screenrc} containing e.g.
#
#    bindkey ^C kill
#
# If you want to change the baudrate, just set MONITOR_BAUDRATE. If you
# don't set it, it tries to read from the sketch. If it couldn't read
# from the sketch, then it defaults to 9600 baud.
#
########################################################################
#
# ARDUINO WITH ISP
#
# You need to specify some details of your ISP programmer and might
# also need to specify the fuse values:
#
#     ISP_PROG	   = stk500v2
#     ISP_PORT     = /dev/ttyACM0
#
# You might also need to set the fuse bits, but typically they'll be
# read from boards.txt, based on the BOARD_TAG variable:
#
#     ISP_LOCK_FUSE_PRE  = 0x3f
#     ISP_LOCK_FUSE_POST = 0xcf
#     ISP_HIGH_FUSE      = 0xdf
#     ISP_LOW_FUSE       = 0xff
#     ISP_EXT_FUSE       = 0x01
#
# You can specify to also upload the EEPROM file:
#     ISP_EEPROM   = 1
#
# I think the fuses here are fine for uploading to the ATmega168
# without bootloader.
#
# To actually do this upload use the ispload target:
#
#    make ispload
#
#
########################################################################
#
# ALTERNATIVE CORES
#
# To use alternative cores for platforms such as ATtiny, you need to
# specify a few more variables, depending on the core in use.
#
# The HLT (attiny-master) core can be used just by specifying
# ALTERNATE_CORE, assuming your core is in your ~/sketchbook/hardware
# directory. For example:
#
# ISP_PORT          = /dev/ttyACM0
# BOARD_TAG         = attiny85
# ALTERNATE_CORE    = attiny-master
#
# To use the more complex arduino-tiny and TinyCore2 cores, you must
# also set ARDUINO_CORE_PATH and ARDUINO_VAR_PATH to the core
# directory, as these cores essentially replace the main Arduino core.
# For example:
#
# ISP_PORT          = /dev/ttyACM0
# BOARD_TAG         = attiny85at8
# ALTERNATE_CORE    = arduino-tiny
# ARDUINO_VAR_PATH  = ~/sketchbook/hardware/arduino-tiny/cores/tiny
# ARDUINO_CORE_PATH = ~/sketchbook/hardware/arduino-tiny/cores/tiny
#
# or....
#
# ISP_PORT          = /dev/ttyACM0
# BOARD_TAG         = attiny861at8
# ALTERNATE_CORE    = tiny2
# ARDUINO_VAR_PATH  = ~/sketchbook/hardware/tiny2/cores/tiny
# ARDUINO_CORE_PATH = ~/sketchbook/hardware/tiny2/cores/tiny
#
########################################################################

arduino_output =
# When output is not suppressed and we're in the top-level makefile,
# running for the first time (i.e., not after a restart after
# regenerating the dependency file), then output the configuration.
ifndef ARDUINO_QUIET
    ifeq ($(MAKE_RESTARTS),)
        ifeq ($(MAKELEVEL),0)
            arduino_output = $(info $(1))
        endif
    endif
endif

# path to boards.txt file that hold board configuration info
BOARDS_TXT = $(PROJECT_DIR)/tools/boards.txt

########################################################################
# Makefile distribution path
#
# include common.mk for helper functions
include ./common.mk
# include paths.mk for default avr tool names and paths
include ./paths.mk
# include core.mk for boards.txt file parsing
include ./core.mk

$(call show_config_variable,ARDMK_DIR,[USER])

########################################################################
# Local sources

LOCAL_C_SRCS    ?= $(wildcard *.c)
LOCAL_CPP_SRCS  ?= $(wildcard *.cpp)
LOCAL_CC_SRCS   ?= $(wildcard *.cc)
LOCAL_PDE_SRCS  ?= $(wildcard *.pde)
LOCAL_INO_SRCS  ?= $(wildcard *.ino)
LOCAL_AS_SRCS   ?= $(wildcard *.S)
LOCAL_SRCS      = $(LOCAL_C_SRCS)   $(LOCAL_CPP_SRCS) \
		$(LOCAL_CC_SRCS)   $(LOCAL_PDE_SRCS) \
		$(LOCAL_INO_SRCS) $(LOCAL_AS_SRCS)
LOCAL_OBJ_FILES = $(LOCAL_C_SRCS:.c=.c.o)   $(LOCAL_CPP_SRCS:.cpp=.cpp.o) \
		$(LOCAL_CC_SRCS:.cc=.cc.o)   $(LOCAL_PDE_SRCS:.pde=.pde.o) \
		$(LOCAL_INO_SRCS:.ino=.ino.o) $(LOCAL_AS_SRCS:.S=.S.o)
LOCAL_OBJS      = $(patsubst %,$(OBJDIR)/%,$(LOCAL_OBJ_FILES))

ifeq ($(words $(LOCAL_SRCS)), 0)
    $(error At least one source file (*.ino, *.pde, *.cpp, *c, *cc, *.S) is needed)
endif

# CHK_SOURCES is used by flymake
# flymake creates a tmp file in the same directory as the file under edition
# we must skip the verification in this particular case
ifeq ($(strip $(CHK_SOURCES)),)
    ifeq ($(strip $(NO_CORE)),)

        # Ideally, this should just check if there are more than one file
        ifneq ($(words $(LOCAL_PDE_SRCS) $(LOCAL_INO_SRCS)), 1)
            ifeq ($(words $(LOCAL_PDE_SRCS) $(LOCAL_INO_SRCS)), 0)
                $(call show_config_info,No .pde or .ino files found. If you are compiling .c or .cpp files then you need to explicitly include Arduino header files)
            else
                #TODO: Support more than one file. https://github.com/sudar/Arduino-Makefile/issues/49
                $(error Need exactly one .pde or .ino file. This makefile doesn\'t support multiple .ino/.pde files yet)
            endif
        endif

    endif
endif

# core sources
ifeq ($(strip $(NO_CORE)),)
    ifdef ARDUINO_CORE_PATH
        CORE_C_SRCS     = $(wildcard $(ARDUINO_CORE_PATH)/*.c)
        CORE_C_SRCS    += $(wildcard $(ARDUINO_CORE_PATH)/avr-libc/*.c)
        CORE_CPP_SRCS   = $(wildcard $(ARDUINO_CORE_PATH)/*.cpp)
        CORE_AS_SRCS    = $(wildcard $(ARDUINO_CORE_PATH)/*.S)

        ifneq ($(strip $(NO_CORE_MAIN_CPP)),)
            CORE_CPP_SRCS := $(filter-out %main.cpp, $(CORE_CPP_SRCS))
            $(call show_config_info,NO_CORE_MAIN_CPP set so core library will not include main.cpp,[MANUAL])
        endif

        CORE_OBJ_FILES  = $(CORE_C_SRCS:.c=.c.o) $(CORE_CPP_SRCS:.cpp=.cpp.o) $(CORE_AS_SRCS:.S=.S.o)
        CORE_OBJS       = $(patsubst $(ARDUINO_CORE_PATH)/%,  \
                $(OBJDIR)/core/%,$(CORE_OBJ_FILES))
    endif
else
    $(call show_config_info,NO_CORE set so core library will not be built,[MANUAL])
endif


########################################################################
# Determine ARDUINO_LIBS automatically

ifndef ARDUINO_LIBS
    # automatically determine included libraries
    ARDUINO_LIBS += $(filter $(notdir $(wildcard $(ARDUINO_DIR)/libraries/*)), \
        $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
    ARDUINO_LIBS += $(filter $(notdir $(wildcard $(ARDUINO_SKETCHBOOK)/libraries/*)), \
        $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
    ARDUINO_LIBS += $(filter $(notdir $(wildcard $(USER_LIB_PATH)/*)), \
        $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
    ARDUINO_LIBS += $(filter $(notdir $(wildcard $(ARDUINO_PLATFORM_LIB_PATH)/*)), \
        $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
endif

########################################################################
# Include Arduino Header file

ifndef ARDUINO_HEADER
    # We should check for Arduino version, not just the file extension
    # because, a .pde file can be used in Arduino 1.0 as well
    ifeq ($(shell expr $(ARDUINO_VERSION) '<' 100), 1)
        ARDUINO_HEADER=WProgram.h
    else
        ARDUINO_HEADER=Arduino.h
    endif
endif

########################################################################
# Rules for making stuff

# The name of the main targets
TARGET_HEX = $(OBJDIR)/$(TARGET).hex
TARGET_ELF = $(OBJDIR)/$(TARGET).elf
TARGET_EEP = $(OBJDIR)/$(TARGET).eep
CORE_LIB   = $(OBJDIR)/libcore.a

# Names of executables - chipKIT needs to override all to set paths to PIC32
# tools, and we can't use "?=" assignment because these are already implicitly
# defined by Make (e.g. $(CC) == cc).
ifndef OVERRIDE_EXECUTABLES
    CC      = $(AVR_TOOLS_PATH)/$(CC_NAME)
    CXX     = $(AVR_TOOLS_PATH)/$(CXX_NAME)
    AS      = $(AVR_TOOLS_PATH)/$(AS_NAME)
    OBJCOPY = $(AVR_TOOLS_PATH)/$(OBJCOPY_NAME)
    OBJDUMP = $(AVR_TOOLS_PATH)/$(OBJDUMP_NAME)
    AR      = $(AVR_TOOLS_PATH)/$(AR_NAME)
    SIZE    = $(AVR_TOOLS_PATH)/$(SIZE_NAME)
    NM      = $(AVR_TOOLS_PATH)/$(NM_NAME)
endif

REMOVE  = rm -rf
MV      = mv -f
CAT     = cat
ECHO    = printf
MKDIR   = mkdir -p

# recursive wildcard function, call with params:
#  - start directory (finished with /) or empty string for current dir
#  - glob pattern
# (taken from http://blog.jgc.org/2011/07/gnu-make-recursive-wildcard-function.html)
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# functions used to determine various properties of library
# called with library path. Needed because of differences between library
# layouts in arduino 1.0.x and 1.5.x.
# Assuming new 1.5.x layout when there is "src" subdirectory in main directory
# and library.properties file

# Gets include flags for library
get_library_includes = $(if $(and $(wildcard $(1)/src), $(wildcard $(1)/library.properties)), \
                           -I$(1)/src, \
                           $(addprefix -I,$(1) $(wildcard $(1)/utility)))

# Gets all sources with given extension (param2) for library (path = param1)
# for old (1.0.x) layout looks in . and "utility" directories
# for new (1.5.x) layout looks in src and recursively its subdirectories
get_library_files  = $(if $(and $(wildcard $(1)/src), $(wildcard $(1)/library.properties)), \
                        $(call rwildcard,$(1)/src/,*.$(2)), \
                        $(wildcard $(1)/*.$(2) $(1)/utility/*.$(2)))

# General arguments
USER_LIBS      := $(sort $(wildcard $(patsubst %,$(USER_LIB_PATH)/%,$(ARDUINO_LIBS))))
USER_LIB_NAMES := $(patsubst $(USER_LIB_PATH)/%,%,$(USER_LIBS))

# Let user libraries override system ones.
SYS_LIBS       := $(sort $(wildcard $(patsubst %,$(ARDUINO_LIB_PATH)/%,$(filter-out $(USER_LIB_NAMES),$(ARDUINO_LIBS)))))
SYS_LIB_NAMES  := $(patsubst $(ARDUINO_LIB_PATH)/%,%,$(SYS_LIBS))

ifdef ARDUINO_PLATFORM_LIB_PATH
    PLATFORM_LIBS       := $(sort $(wildcard $(patsubst %,$(ARDUINO_PLATFORM_LIB_PATH)/%,$(filter-out $(USER_LIB_NAMES),$(ARDUINO_LIBS)))))
    PLATFORM_LIB_NAMES  := $(patsubst $(ARDUINO_PLATFORM_LIB_PATH)/%,%,$(PLATFORM_LIBS))
endif


# Error here if any are missing.
LIBS_NOT_FOUND = $(filter-out $(USER_LIB_NAMES) $(SYS_LIB_NAMES) $(PLATFORM_LIB_NAMES),$(ARDUINO_LIBS))
ifneq (,$(strip $(LIBS_NOT_FOUND)))
    ifdef ARDUINO_PLATFORM_LIB_PATH
        $(error The following libraries specified in ARDUINO_LIBS could not be found (searched USER_LIB_PATH, ARDUINO_LIB_PATH and ARDUINO_PLATFORM_LIB_PATH): $(LIBS_NOT_FOUND))
    else
        $(error The following libraries specified in ARDUINO_LIBS could not be found (searched USER_LIB_PATH and ARDUINO_LIB_PATH): $(LIBS_NOT_FOUND))
    endif
endif

SYS_INCLUDES        := $(foreach lib, $(SYS_LIBS),  $(call get_library_includes,$(lib)))
USER_INCLUDES       := $(foreach lib, $(USER_LIBS), $(call get_library_includes,$(lib)))
LIB_C_SRCS          := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),c))
LIB_CPP_SRCS        := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),cpp))
LIB_AS_SRCS         := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),S))
USER_LIB_CPP_SRCS   := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),cpp))
USER_LIB_C_SRCS     := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),c))
USER_LIB_AS_SRCS    := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),S))
LIB_OBJS            = $(patsubst $(ARDUINO_LIB_PATH)/%.c,$(OBJDIR)/libs/%.c.o,$(LIB_C_SRCS)) \
                      $(patsubst $(ARDUINO_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.cpp.o,$(LIB_CPP_SRCS)) \
                      $(patsubst $(ARDUINO_LIB_PATH)/%.S,$(OBJDIR)/libs/%.S.o,$(LIB_AS_SRCS))
USER_LIB_OBJS       = $(patsubst $(USER_LIB_PATH)/%.cpp,$(OBJDIR)/userlibs/%.cpp.o,$(USER_LIB_CPP_SRCS)) \
                      $(patsubst $(USER_LIB_PATH)/%.c,$(OBJDIR)/userlibs/%.c.o,$(USER_LIB_C_SRCS)) \
                      $(patsubst $(USER_LIB_PATH)/%.S,$(OBJDIR)/userlibs/%.S.o,$(USER_LIB_AS_SRCS))

ifdef ARDUINO_PLATFORM_LIB_PATH
    PLATFORM_INCLUDES     := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_includes,$(lib)))
    PLATFORM_LIB_CPP_SRCS := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_files,$(lib),cpp))
    PLATFORM_LIB_C_SRCS   := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_files,$(lib),c))
    PLATFORM_LIB_AS_SRCS  := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_files,$(lib),S))
    PLATFORM_LIB_OBJS     := $(patsubst $(ARDUINO_PLATFORM_LIB_PATH)/%.cpp,$(OBJDIR)/platformlibs/%.cpp.o,$(PLATFORM_LIB_CPP_SRCS)) \
                             $(patsubst $(ARDUINO_PLATFORM_LIB_PATH)/%.c,$(OBJDIR)/platformlibs/%.c.o,$(PLATFORM_LIB_C_SRCS)) \
                             $(patsubst $(ARDUINO_PLATFORM_LIB_PATH)/%.S,$(OBJDIR)/platformlibs/%.S.o,$(PLATFORM_LIB_AS_SRCS))

endif

# Dependency files
DEPS                = $(LOCAL_OBJS:.o=.d) $(LIB_OBJS:.o=.d) $(PLATFORM_OBJS:.o=.d) $(USER_LIB_OBJS:.o=.d) $(CORE_OBJS:.o=.d)

# Optimization level for the compiler.
# You can get the list of options at http://www.nongnu.org/avr-libc/user-manual/using_tools.html#gcc_optO
# Also read http://www.nongnu.org/avr-libc/user-manual/FAQ.html#faq_optflags
ifndef OPTIMIZATION_LEVEL
    OPTIMIZATION_LEVEL=s
    $(call show_config_variable,OPTIMIZATION_LEVEL,[DEFAULT])
else
    $(call show_config_variable,OPTIMIZATION_LEVEL,[USER])
endif

ifndef DEBUG_FLAGS
    DEBUG_FLAGS = -O0 -g
endif

# SoftwareSerial requires -Os (some delays are tuned for this optimization level)
%SoftwareSerial.cpp.o : OPTIMIZATION_FLAGS = -Os

ifndef MCU_FLAG_NAME
    MCU_FLAG_NAME = mmcu
    $(call show_config_variable,MCU_FLAG_NAME,[DEFAULT])
else
    $(call show_config_variable,MCU_FLAG_NAME,[USER])
endif

# Using += instead of =, so that CPPFLAGS can be set per sketch level
CPPFLAGS      += -$(MCU_FLAG_NAME)=$(MCU) -DF_CPU=$(F_CPU) -DARDUINO=$(ARDUINO_VERSION) $(ARDUINO_ARCH_FLAG) -D__PROG_TYPES_COMPAT__ \
        -I$(ARDUINO_CORE_PATH) -I$(ARDUINO_VAR_PATH)/$(VARIANT) \
        $(SYS_INCLUDES) $(PLATFORM_INCLUDES) $(USER_INCLUDES) -Wall -ffunction-sections \
        -fdata-sections

ifdef DEBUG
OPTIMIZATION_FLAGS= $(DEBUG_FLAGS)
else
OPTIMIZATION_FLAGS = -O$(OPTIMIZATION_LEVEL)
endif

CPPFLAGS += $(OPTIMIZATION_FLAGS)

# USB IDs for the Caterina devices like leonardo or micro
ifneq ($(CATERINA),)
    CPPFLAGS += -DUSB_VID=$(USB_VID) -DUSB_PID=$(USB_PID)
endif

ifndef CFLAGS_STD
    CFLAGS_STD        =
    $(call show_config_variable,CFLAGS_STD,[DEFAULT])
else
    $(call show_config_variable,CFLAGS_STD,[USER])
endif

ifndef CXXFLAGS_STD
    CXXFLAGS_STD      =
    $(call show_config_variable,CXXFLAGS_STD,[DEFAULT])
else
    $(call show_config_variable,CXXFLAGS_STD,[USER])
endif

CFLAGS        += $(CFLAGS_STD)
CXXFLAGS      += -fno-exceptions $(CXXFLAGS_STD)
ASFLAGS       += -x assembler-with-cpp
LDFLAGS       += -$(MCU_FLAG_NAME)=$(MCU) -Wl,--gc-sections -O$(OPTIMIZATION_LEVEL)
SIZEFLAGS     ?= --mcu=$(MCU) -C

# for backwards compatibility, grab ARDUINO_PORT if the user has it set
# instead of MONITOR_PORT
MONITOR_PORT ?= $(ARDUINO_PORT)

ifneq ($(strip $(MONITOR_PORT)),)
    ifeq ($(CURRENT_OS), WINDOWS)
        # Expect MONITOR_PORT to be '1' or 'com1' for COM1 in Windows. Split it up
        # into the two styles required: /dev/ttyS* for ard-reset-arduino and com*
        # for avrdude. This also could work with /dev/com* device names and be more
        # consistent, but the /dev/com* is not recommended by Cygwin and doesn't
        # always show up.
        COM_PORT_ID = $(subst com,,$(MONITOR_PORT))
        COM_STYLE_MONITOR_PORT = com$(COM_PORT_ID)
        DEVICE_PATH = /dev/ttyS$(shell awk 'BEGIN{ print $(COM_PORT_ID) - 1 }')
    else
        # set DEVICE_PATH based on user-defined MONITOR_PORT or ARDUINO_PORT
        DEVICE_PATH = $(MONITOR_PORT)
    endif
    $(call show_config_variable,DEVICE_PATH,[COMPUTED],(from MONITOR_PORT))
else
    # If no port is specified, try to guess it from wildcards.
    # Will only work if the Arduino is the only/first device matched.
    DEVICE_PATH = $(firstword $(wildcard \
			/dev/ttyACM? /dev/ttyUSB? /dev/tty.usbserial* /dev/tty.usbmodem* /dev/tty.wchusbserial*))
    $(call show_config_variable,DEVICE_PATH,[AUTODETECTED])
endif

ifndef FORCE_MONITOR_PORT
    $(call show_config_variable,FORCE_MONITOR_PORT,[DEFAULT])
else
    $(call show_config_variable,FORCE_MONITOR_PORT,[USER])
endif

ifdef FORCE_MONITOR_PORT
    # Skips the DEVICE_PATH existance check.
    get_monitor_port = $(DEVICE_PATH)
else
    # Returns the Arduino port (first wildcard expansion) if it exists, otherwise it errors.
    ifeq ($(CURRENT_OS), WINDOWS)
        get_monitor_port = $(COM_STYLE_MONITOR_PORT)
    else
        get_monitor_port = $(if $(wildcard $(DEVICE_PATH)),$(firstword $(wildcard $(DEVICE_PATH))),$(error Arduino port $(DEVICE_PATH) not found!))
    endif
endif

# Returns the ISP port (first wildcard expansion) if it exists, otherwise it errors.
get_isp_port = $(if $(wildcard $(ISP_PORT)),$(firstword $(wildcard $(ISP_PORT))),$(if $(findstring Xusb,X$(ISP_PORT)),$(ISP_PORT),$(error ISP port $(ISP_PORT) not found!)))

# Command for avr_size: do $(call avr_size,elffile,hexfile)
ifneq (,$(findstring AVR,$(shell $(SIZE) --help)))
    # We have a patched version of binutils that mentions AVR - pass the MCU
    # and the elf to get nice output.
    avr_size = $(SIZE) $(SIZEFLAGS) --format=avr $(1)
    $(call show_config_info,Size utility: AVR-aware for enhanced output,[AUTODETECTED])
else
    # We have a plain-old binutils version - just give it the hex.
    avr_size = $(SIZE) $(2)
    $(call show_config_info,Size utility: Basic (not AVR-aware),[AUTODETECTED])
endif

ifneq (,$(strip $(ARDUINO_LIBS)))
    $(call arduino_output,-)
    $(call show_config_info,ARDUINO_LIBS =)
endif

ifneq (,$(strip $(USER_LIB_NAMES)))
    $(foreach lib,$(USER_LIB_NAMES),$(call show_config_info,  $(lib),[USER]))
endif

ifneq (,$(strip $(SYS_LIB_NAMES)))
    $(foreach lib,$(SYS_LIB_NAMES),$(call show_config_info,  $(lib),[SYSTEM]))
endif

ifneq (,$(strip $(PLATFORM_LIB_NAMES)))
    $(foreach lib,$(PLATFORM_LIB_NAMES),$(call show_config_info,  $(lib),[PLATFORM]))
endif

# either calculate parent dir from arduino dir, or user-defined path
ifndef BOOTLOADER_PARENT
    BOOTLOADER_PARENT = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/bootloaders
    $(call show_config_variable,BOOTLOADER_PARENT,[COMPUTED],(from ARDUINO_DIR))
else
    $(call show_config_variable,BOOTLOADER_PARENT,[USER])
endif

########################################################################
# Tools version info
ARDMK_VERSION = 1.5
$(call show_config_variable,ARDMK_VERSION,[COMPUTED])

CC_VERSION := $(shell $(CC) -dumpversion)
$(call show_config_variable,CC_VERSION,[COMPUTED],($(CC_NAME)))

# end of config output
$(call show_separator)

# Implicit rules for building everything (needed to get everything in
# the right directory)
#
# Rather than mess around with VPATH there are quasi-duplicate rules
# here for building e.g. a system C++ file and a local C++
# file. Besides making things simpler now, this would also make it
# easy to change the build options in future

# library sources
$(OBJDIR)/libs/%.c.o: $(ARDUINO_LIB_PATH)/%.c
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/libs/%.cpp.o: $(ARDUINO_LIB_PATH)/%.cpp
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/libs/%.S.o: $(ARDUINO_LIB_PATH)/%.S
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/platformlibs/%.c.o: $(ARDUINO_PLATFORM_LIB_PATH)/%.c
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/platformlibs/%.cpp.o: $(ARDUINO_PLATFORM_LIB_PATH)/%.cpp
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/platformlibs/%.S.o: $(ARDUINO_PLATFORM_LIB_PATH)/%.S
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/userlibs/%.cpp.o: $(USER_LIB_PATH)/%.cpp
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/userlibs/%.c.o: $(USER_LIB_PATH)/%.c
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/userlibs/%.S.o: $(USER_LIB_PATH)/%.S
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

ifdef COMMON_DEPS
    COMMON_DEPS := $(COMMON_DEPS) $(MAKEFILE_LIST)
else
    COMMON_DEPS := $(MAKEFILE_LIST)
endif

# normal local sources
$(OBJDIR)/%.c.o: %.c $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/%.cc.o: %.cc $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.cpp.o: %.cpp $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.S.o: %.S $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/%.s.o: %.s $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

# the pde -> o file
$(OBJDIR)/%.pde.o: %.pde $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -x c++ -include $(ARDUINO_HEADER) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# the ino -> o file
$(OBJDIR)/%.ino.o: %.ino $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -x c++ -include $(ARDUINO_HEADER) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# generated assembly
$(OBJDIR)/%.s: %.pde $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -x c++ -include $(ARDUINO_HEADER) -MMD -S -fverbose-asm $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.s: %.ino $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -x c++ -include $(ARDUINO_HEADER) -MMD -S -fverbose-asm $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.s: %.cpp $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -x c++ -include $(ARDUINO_HEADER) -MMD -S -fverbose-asm $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# core files
$(OBJDIR)/core/%.c.o: $(ARDUINO_CORE_PATH)/%.c $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/core/%.cpp.o: $(ARDUINO_CORE_PATH)/%.cpp $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/core/%.S.o: $(ARDUINO_CORE_PATH)/%.S $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

# various object conversions
$(OBJDIR)/%.hex: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(OBJCOPY) -O ihex -R .eeprom $< $@
	@$(ECHO) '\n'
	$(call avr_size,$<,$@)
ifneq ($(strip $(HEX_MAXIMUM_SIZE)),)
	@if [ `$(SIZE) $@ | awk 'FNR == 2 {print $$2}'` -le $(HEX_MAXIMUM_SIZE) ]; then touch $@.sizeok; fi
else
	@$(ECHO) "Maximum flash memory of $(BOARD_TAG) is not specified. Make sure the size of $@ is less than $(BOARD_TAG)\'s flash memory"
	@touch $@.sizeok
endif

$(OBJDIR)/%.eep: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom='alloc,load' \
		--change-section-lma .eeprom=0 -O ihex $< $@

$(OBJDIR)/%.lss: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(OBJDUMP) -h --source --demangle --wide $< > $@

$(OBJDIR)/%.sym: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(NM) --size-sort --demangle --reverse-sort --line-numbers $< > $@

# include avrdude configuration
include ./avrdude.mk
# include serial monitor functionality
include ./monitor.mk

########################################################################
# Explicit targets start here

all: 		$(TARGET_EEP) $(TARGET_HEX)

# Rule to create $(OBJDIR) automatically. All rules with recipes that
# create a file within it, but do not already depend on a file within it
# should depend on this rule. They should use a "order-only
# prerequisite" (e.g., put "| $(OBJDIR)" at the end of the prerequisite
# list) to prevent remaking the target when any file in the directory
# changes.
$(OBJDIR): pre-build
		$(MKDIR) $(OBJDIR)

pre-build:
		$(call runscript_if_exists,$(PRE_BUILD_HOOK))

$(TARGET_ELF): 	$(LOCAL_OBJS) $(CORE_LIB) $(OTHER_OBJS)
		$(CC) $(LDFLAGS) -o $@ $(LOCAL_OBJS) $(CORE_LIB) $(OTHER_OBJS) -lc -lm $(LINKER_SCRIPTS)

$(CORE_LIB):	$(CORE_OBJS) $(LIB_OBJS) $(PLATFORM_LIB_OBJS) $(USER_LIB_OBJS)
		$(AR) rcs $@ $(CORE_OBJS) $(LIB_OBJS) $(PLATFORM_LIB_OBJS) $(USER_LIB_OBJS)

error_on_caterina:
		$(ERROR_ON_CATERINA)


# Use submake so we can guarantee the reset happens
# before the upload, even with make -j
upload:		$(TARGET_HEX) verify_size
		$(MAKE) reset
		$(MAKE) do_upload

raw_upload:	$(TARGET_HEX) verify_size
		$(MAKE) error_on_caterina
		$(MAKE) do_upload

do_upload:
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ARD_OPTS) \
			$(AVRDUDE_UPLOAD_HEX)

do_eeprom:	$(TARGET_EEP) $(TARGET_HEX)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ARD_OPTS) \
			$(AVRDUDE_UPLOAD_EEP)

eeprom:		$(TARGET_HEX) verify_size
		$(MAKE) reset
		$(MAKE) do_eeprom

raw_eeprom:	$(TARGET_HEX) verify_size
		$(MAKE) error_on_caterina
		$(MAKE) do_eeprom

reset:
		$(call arduino_output,Resetting Arduino...)
		$(RESET_CMD)

# stty on MacOS likes -F, but on Debian it likes -f redirecting
# stdin/out appears to work but generates a spurious error on MacOS at
# least. Perhaps it would be better to just do it in perl ?
reset_stty:
		for STTYF in 'stty -F' 'stty --file' 'stty -f' 'stty <' ; \
		  do $$STTYF /dev/tty >/dev/null 2>&1 && break ; \
		done ; \
		$$STTYF $(call get_monitor_port)  hupcl ; \
		(sleep 0.1 2>/dev/null || sleep 1) ; \
		$$STTYF $(call get_monitor_port) -hupcl

ispload:	$(TARGET_EEP) $(TARGET_HEX) verify_size
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) \
			$(AVRDUDE_ISPLOAD_OPTS)

burn_bootloader:
ifneq ($(strip $(AVRDUDE_ISP_FUSES_PRE)),)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -e $(AVRDUDE_ISP_FUSES_PRE)
endif
ifneq ($(strip $(AVRDUDE_ISP_BURN_BOOTLOADER)),)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) $(AVRDUDE_ISP_BURN_BOOTLOADER)
endif
ifneq ($(strip $(AVRDUDE_ISP_FUSES_POST)),)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) $(AVRDUDE_ISP_FUSES_POST)
endif

set_fuses:
ifneq ($(strip $(AVRDUDE_ISP_FUSES_PRE)),)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) -e $(AVRDUDE_ISP_FUSES_PRE)
endif
ifneq ($(strip $(AVRDUDE_ISP_FUSES_POST)),)
		$(AVRDUDE) $(AVRDUDE_COM_OPTS) $(AVRDUDE_ISP_OPTS) $(AVRDUDE_ISP_FUSES_POST)
endif

clean::
		$(REMOVE) $(OBJDIR)

size:	$(TARGET_HEX)
		$(call avr_size,$(TARGET_ELF),$(TARGET_HEX))

show_boards:
		@$(CAT) $(BOARDS_TXT) | grep -E '^[a-zA-Z0-9_]+.name' | sort -uf | sed 's/.name=/:/' | column -s: -t

monitor:
ifeq ($(MONITOR_CMD), 'putty')
	ifneq ($(strip $(MONITOR_PARMS)),)
	$(MONITOR_CMD) -serial -sercfg $(MONITOR_BAUDRATE),$(MONITOR_PARMS) $(call get_monitor_port)
	else
	$(MONITOR_CMD) -serial -sercfg $(MONITOR_BAUDRATE) $(call get_monitor_port)
	endif
else ifeq ($(MONITOR_CMD), picocom)
		$(MONITOR_CMD) -b $(MONITOR_BAUDRATE) $(MONITOR_PARAMS) $(call get_monitor_port)
else
		$(MONITOR_CMD) $(call get_monitor_port) $(MONITOR_BAUDRATE)
endif

disasm: $(OBJDIR)/$(TARGET).lss
		@$(ECHO) "The compiled ELF file has been disassembled to $(OBJDIR)/$(TARGET).lss\n\n"

symbol_sizes: $(OBJDIR)/$(TARGET).sym
		@$(ECHO) "A symbol listing sorted by their size have been dumped to $(OBJDIR)/$(TARGET).sym\n\n"

verify_size:
ifeq ($(strip $(HEX_MAXIMUM_SIZE)),)
	@$(ECHO) "\nMaximum flash memory of $(BOARD_TAG) is not specified. Make sure the size of $(TARGET_HEX) is less than $(BOARD_TAG)\'s flash memory\n\n"
endif
	@if [ ! -f $(TARGET_HEX).sizeok ]; then echo >&2 "\nThe size of the compiled binary file is greater than the $(BOARD_TAG)'s flash memory. \
See http://www.arduino.cc/en/Guide/Troubleshooting#size for tips on reducing it."; false; fi

generate_assembly: $(OBJDIR)/$(TARGET).s
		@$(ECHO) "Compiler-generated assembly for the main input source has been dumped to $(OBJDIR)/$(TARGET).s\n\n"

generated_assembly: generate_assembly
		@$(ECHO) "\"generated_assembly\" target is deprecated. Use \"generate_assembly\" target instead\n\n"

help_vars:
		@$(CAT) $(ARDMK_DIR)/arduino-mk-vars.md

help:
		@$(ECHO) "\nAvailable targets:\n\
  make                   - compile the code\n\
  make upload            - upload\n\
  make ispload           - upload using an ISP\n\
  make raw_upload        - upload without first resetting\n\
  make eeprom            - upload the eep file\n\
  make raw_eeprom        - upload the eep file without first resetting\n\
  make clean             - remove all our dependencies\n\
  make depends           - update dependencies\n\
  make reset             - reset the Arduino by tickling DTR or changing baud\n\
                           rate on the serial port.\n\
  make show_boards       - list all the boards defined in boards.txt\n\
  make monitor           - connect to the Arduino's serial port\n\
  make size              - show the size of the compiled output (relative to\n\
                           resources, if you have a patched avr-size).\n\
  make verify_size       - verify that the size of the final file is less than\n\
                           the capacity of the micro controller.\n\
  make symbol_sizes      - generate a .sym file containing symbols and their\n\
                           sizes.\n\
  make disasm            - generate a .lss file that contains disassembly\n\
                           of the compiled file interspersed with your\n\
                           original source code.\n\
  make generate_assembly - generate a .s file containing the compiler\n\
                           generated assembly of the main sketch.\n\
  make burn_bootloader   - burn bootloader and fuses\n\
  make set_fuses         - set fuses without burning bootloader\n\
  make help_vars         - print all variables that can be overridden\n\
  make help              - show this help\n\
"
	@$(ECHO) "Please refer to $(ARDMK_DIR)/Arduino.mk for more details.\n"

.PHONY: all upload raw_upload raw_eeprom error_on_caterina reset reset_stty ispload \
        clean depends size show_boards monitor disasm symbol_sizes generated_assembly \
        generate_assembly verify_size burn_bootloader help pre-build

# added - in the beginning, so that we don't get an error if the file is not present
-include $(DEPS)
