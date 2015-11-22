########################################################################
# Arduino and system paths

ifndef CC_NAME
CC_NAME      = avr-gcc
endif

ifndef CXX_NAME
CXX_NAME     = avr-g++
endif

ifndef OBJCOPY_NAME
OBJCOPY_NAME = avr-objcopy
endif

ifndef OBJDUMP_NAME
OBJDUMP_NAME = avr-objdump
endif

ifndef AR_NAME
AR_NAME      = avr-ar
endif

ifndef SIZE_NAME
SIZE_NAME    = avr-size
endif

ifndef NM_NAME
NM_NAME      = avr-nm
endif

ifndef AVR_TOOLS_DIR

		# first look for encapsulated avr tools
    BUNDLED_AVR_TOOLS_DIR := $(call dir_if_exists,$(ARDUINO_DIR)/hardware/tools/avr)

    ifdef BUNDLED_AVR_TOOLS_DIR
        AVR_TOOLS_DIR     = $(BUNDLED_AVR_TOOLS_DIR)
        $(call show_config_variable,AVR_TOOLS_DIR,[BUNDLED],(in Arduino distribution))
        # In Linux distribution of Arduino, the path to avrdude and avrdude.conf are different
        # More details at https://github.com/sudar/Arduino-Makefile/issues/48 and
        # https://groups.google.com/a/arduino.cc/d/msg/developers/D_m97jGr8Xs/uQTt28KO_8oJ
        ifeq ($(CURRENT_OS),LINUX)
            ifndef AVRDUDE
                ifeq ($(shell expr $(ARDUINO_VERSION) '>' 157), 1)
                    # 1.5.8 has different location than all prior versions!
                    AVRDUDE = $(AVR_TOOLS_DIR)/bin/avrdude
                else
                    AVRDUDE = $(AVR_TOOLS_DIR)/../avrdude
                endif
            endif

            ifndef AVRDUDE_CONF
                ifeq ($(shell expr $(ARDUINO_VERSION) '>' 157), 1)
                    AVRDUDE_CONF = $(AVR_TOOLS_DIR)/etc/avrdude.conf
                else
                    AVRDUDE_CONF = $(AVR_TOOLS_DIR)/../avrdude.conf
                endif
            endif
        else
            ifndef AVRDUDE_CONF
                AVRDUDE_CONF  = $(AVR_TOOLS_DIR)/etc/avrdude.conf
            endif
        endif

    else
				# otherwise load system avr tools
        SYSTEMPATH_AVR_TOOLS_DIR := $(call dir_if_exists,$(abspath $(dir $(shell which $(CC_NAME)))/..))
        ifdef SYSTEMPATH_AVR_TOOLS_DIR
            AVR_TOOLS_DIR = $(SYSTEMPATH_AVR_TOOLS_DIR)
            $(call show_config_variable,AVR_TOOLS_DIR,[AUTODETECTED],(found in $$PATH))
        else
            echo $(error No AVR tools directory found)
        endif # SYSTEMPATH_AVR_TOOLS_DIR
    endif # BUNDLED_AVR_TOOLS_DIR

else
    $(call show_config_variable,AVR_TOOLS_DIR,[USER])
    # ensure we can still find avrdude.conf
    ifndef AVRDUDE_CONF
        ifeq ($(shell expr $(ARDUINO_VERSION) '>' 157), 1)
            AVRDUDE_CONF = $(AVR_TOOLS_DIR)/etc/avrdude.conf
        else
            AVRDUDE_CONF = $(AVR_TOOLS_DIR)/../avrdude.conf
        endif
    endif
endif #ndef AVR_TOOLS_DIR

ifndef AVR_TOOLS_PATH
    AVR_TOOLS_PATH    = $(AVR_TOOLS_DIR)/bin
endif

# arduino libraries are in the main directory now
ARDUINO_LIB_PATH  = $(PROJECT_DIR)
$(call show_config_variable,ARDUINO_LIB_PATH,[COMPUTED],(from ARDUINO_DIR))

########################################################################
# Miscellaneous

ifndef USER_LIB_PATH
    USER_LIB_PATH = $(PROJECT_DIR)
    $(call show_config_variable,USER_LIB_PATH,[DEFAULT],(in user sketchbook))
else
    $(call show_config_variable,USER_LIB_PATH,[USER])
endif

#ifndef PRE_BUILD_HOOK
#    PRE_BUILD_HOOK = pre-build-hook.sh
#    $(call show_config_variable,PRE_BUILD_HOOK,[DEFAULT])
#else
#    $(call show_config_variable,PRE_BUILD_HOOK,[USER])
#endif
