# Useful functions
# Returns the first argument (typically a directory), if the file or directory
# named by concatenating the first and optionally second argument
# (directory and optional filename) exists
dir_if_exists = $(if $(wildcard $(1)$(2)),$(1))

# Run a shell script if it exists. Stops make on error.
runscript_if_exists =                                                          \
    $(if $(wildcard $(1)),                                                     \
         $(if $(findstring 0,                                                  \
                  $(lastword $(shell $(abspath $(wildcard $(1))); echo $$?))), \
              $(info Info: $(1) success),                                      \
              $(error ERROR: $(1) failed)))

# For message printing: pad the right side of the first argument with spaces to
# the number of bytes indicated by the second argument.
space_pad_to = $(shell echo $(1) "                                                      " | head -c$(2))

# Call with some text, and a prefix tag if desired (like [AUTODETECTED]),
show_config_info = $(call arduino_output,- $(call space_pad_to,$(2),20) $(1))

# Call with the name of the variable, a prefix tag if desired (like [AUTODETECTED]),
# and an explanation if desired (like (found in $$PATH)
show_config_variable = $(call show_config_info,$(1) = $($(1)) $(3),$(2))

# Just a nice simple visual separator
show_separator = $(call arduino_output,-------------------------)

$(call show_separator)
$(call arduino_output,Arduino.mk Configuration:)

########################################################################
#
# Detect OS
ifeq ($(OS),Windows_NT)
    CURRENT_OS = WINDOWS
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        CURRENT_OS = LINUX
    endif
    ifeq ($(UNAME_S),Darwin)
        CURRENT_OS = MAC
    endif
endif
$(call show_config_variable,CURRENT_OS,[AUTODETECTED])

########################################################################
#
# Travis-CI
ifneq ($(TEST),)
       DEPENDENCIES_DIR = /var/tmp/Arduino-Makefile-testing-dependencies

       DEPENDENCIES_MPIDE_DIR = $(DEPENDENCIES_DIR)/mpide-0023-linux64-20130817-test
       ifeq ($(MPIDE_DIR),)
              MPIDE_DIR = $(DEPENDENCIES_MPIDE_DIR)
       endif

       DEPENDENCIES_ARDUINO_DIR = $(DEPENDENCIES_DIR)/arduino-1.0.6
       ifeq ($(ARDUINO_DIR),)
              ARDUINO_DIR = $(DEPENDENCIES_ARDUINO_DIR)
       endif
endif

########################################################################
# Arduino Directory

ifndef ARDUINO_DIR
    AUTO_ARDUINO_DIR := $(firstword \
        $(call dir_if_exists,/usr/share/arduino) \
        $(call dir_if_exists,/Applications/Arduino.app/Contents/Resources/Java) \
        $(call dir_if_exists,/Applications/Arduino.app/Contents/Java) )
    ifdef AUTO_ARDUINO_DIR
       ARDUINO_DIR = $(AUTO_ARDUINO_DIR)
       $(call show_config_variable,ARDUINO_DIR,[AUTODETECTED])
    else
        echo $(error "ARDUINO_DIR is not defined")
    endif
else
    $(call show_config_variable,ARDUINO_DIR,[USER])
endif

ifeq ($(CURRENT_OS),WINDOWS)
    ifneq ($(shell echo $(ARDUINO_DIR) | egrep '^(/|[a-zA-Z]:\\)'),)
        echo $(error On Windows, ARDUINO_DIR must be a relative path)
    endif
endif

# Remove all the decimals, and right-pad with zeros, and finally grab the first 3 bytes.
# Works for 1.0 and 1.0.1
VERSION_FILE := $(ARDUINO_DIR)/version.txt
AUTO_ARDUINO_VERSION := $(shell [ -e $(VERSION_FILE) ] && cat $(VERSION_FILE) | sed -e 's/^[0-9]://g' -e 's/[.]//g' -e 's/$$/0000/' | head -c3)
ifdef AUTO_ARDUINO_VERSION
		ARDUINO_VERSION = $(AUTO_ARDUINO_VERSION)
		$(call show_config_variable,ARDUINO_VERSION,[AUTODETECTED])
else
		ARDUINO_VERSION = 100
		$(call show_config_variable,ARDUINO_VERSION,[DEFAULT])
endif


########################################################################
# Default TARGET to pwd (ex Daniele Vergini)

ifndef TARGET
    space :=
    space +=
    TARGET = $(notdir $(subst $(space),_,$(CURDIR)))
endif

########################################################################
# Reset

ifndef RESET_CMD
	ARD_RESET_ARDUINO := $(shell which ard-reset-arduino 2> /dev/null)
	ifndef ARD_RESET_ARDUINO
		# same level as *.mk in bin directory when checked out from git
		# or in $PATH when packaged
		ARD_RESET_ARDUINO = $(ARDMK_DIR)/bin/ard-reset-arduino
	endif
    ifneq ($(CATERINA),)
        ifneq (,$(findstring CYGWIN,$(shell uname -s)))
            RESET_CMD = $(ARD_RESET_ARDUINO) --caterina $(ARD_RESET_OPTS) $(DEVICE_PATH)
        else
            RESET_CMD = $(ARD_RESET_ARDUINO) --caterina $(ARD_RESET_OPTS) $(call get_monitor_port)
        endif
    else
        ifneq (,$(findstring CYGWIN,$(shell uname -s)))
            RESET_CMD = $(ARD_RESET_ARDUINO) $(ARD_RESET_OPTS) $(DEVICE_PATH)
        else
            RESET_CMD = $(ARD_RESET_ARDUINO) $(ARD_RESET_OPTS) $(call get_monitor_port)
        endif
    endif
endif

ifneq ($(CATERINA),)
    ERROR_ON_CATERINA = $(error On $(BOARD_TAG), raw_xxx operation is not supported)
else
    ERROR_ON_CATERINA =
endif

