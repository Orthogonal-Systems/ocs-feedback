# boards.txt parsing

# tool for parsing the tools/boards.txt file
ifndef PARSE_BOARD
    # result = $(call READ_BOARD_TXT, 'boardname', 'parameter')
    PARSE_BOARD = $(shell grep -v '^\#' $(BOARDS_TXT) | grep "^[ \t]*$(1).$(2)=" | cut -d = -f 2)
endif


ifdef BOARD_SUB
    BOARD_SUB := $(strip $(BOARD_SUB))
    $(call show_config_variable,BOARD_SUB,[USER])
endif

# board tag is the board type i.e. uno
ifndef BOARD_TAG
    BOARD_TAG   = uno
    $(call show_config_variable,BOARD_TAG,[DEFAULT])
else
    # Strip the board tag of any extra whitespace, since it was causing the makefile to fail
    # https://github.com/sudar/Arduino-Makefile/issues/57
    BOARD_TAG := $(strip $(BOARD_TAG))
    $(call show_config_variable,BOARD_TAG,[USER])
endif


# If NO_CORE is set, then we don't have to parse boards.txt file
# But the user might have to define MCU, F_CPU etc
ifeq ($(strip $(NO_CORE)),)

    # Select a core from the 'cores' directory. Two main values: 'arduino' or
    # 'robot', but can also hold 'tiny', for example, if using
    # https://code.google.com/p/arduino-tiny alternate core.
    ifndef CORE
				# read the core from the boards.txt file line with: [BOARD_TAG].build.core=[CORE]
        CORE = $(call PARSE_BOARD,$(BOARD_TAG),build.core)
        $(call show_config_variable,CORE,[COMPUTED],(from build.core))
    else
        $(call show_config_variable,CORE,[USER])
    endif

    # Which variant ? This affects the include path
		# not really sure what this means
    ifndef VARIANT
				VARIANT := $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
        $(call show_config_variable,VARIANT,[COMPUTED],(from build.variant))
    else
        $(call show_config_variable,VARIANT,[USER])
    endif

    # the mcu type
    ifndef MCU
				MCU := $(call PARSE_BOARD,$(BOARD_TAG),build.mcu)
    endif

		# CPU frequency
    ifndef F_CPU
				F_CPU := $(call PARSE_BOARD,$(BOARD_TAG),build.f_cpu)
    endif

    # normal programming info, typically arduino
    ifndef AVRDUDE_ARD_PROGRAMMER
				AVRDUDE_ARD_PROGRAMMER := $(call PARSE_BOARD,$(BOARD_TAG),upload.protocol)
    endif

		# serial upload baud
    ifndef AVRDUDE_ARD_BAUDRATE
				AVRDUDE_ARD_BAUDRATE := $(call PARSE_BOARD,$(BOARD_TAG),upload.speed)
    endif

    # fuses if you're using e.g. ISP
    ifndef ISP_LOCK_FUSE_PRE
        ISP_LOCK_FUSE_PRE = $(call PARSE_BOARD,$(BOARD_TAG),bootloader.unlock_bits)
    endif

		# fuses
    ifndef ISP_HIGH_FUSE
				ISP_HIGH_FUSE := $(call PARSE_BOARD,$(BOARD_TAG),bootloader.high_fuses)
    endif

		# fuses
    ifndef ISP_LOW_FUSE
				ISP_LOW_FUSE := $(call PARSE_BOARD,$(BOARD_TAG),bootloader.low_fuses)
    endif

		# fuses
    ifndef ISP_EXT_FUSE
				ISP_EXT_FUSE := $(call PARSE_BOARD,$(BOARD_TAG),bootloader.extended_fuses)
    endif

		# bootloader
    ifndef BOOTLOADER_PATH
        BOOTLOADER_PATH = $(call PARSE_BOARD,$(BOARD_TAG),bootloader.path)
    endif

    ifndef BOOTLOADER_FILE
				BOOTLOADER_FILE := $(call PARSE_BOARD,$(BOARD_TAG),bootloader.file)
    endif

    ifndef ISP_LOCK_FUSE_POST
        ISP_LOCK_FUSE_POST = $(call PARSE_BOARD,$(BOARD_TAG),bootloader.lock_bits)
    endif

    ifndef HEX_MAXIMUM_SIZE
				HEX_MAXIMUM_SIZE := $(call PARSE_BOARD,$(BOARD_TAG),upload.maximum_size)
    endif

endif

# Everything gets built in here (include BOARD_TAG now)
ifndef OBJDIR
    OBJDIR = build-$(BOARD_TAG)
    ifdef BOARD_SUB
        OBJDIR = build-$(BOARD_TAG)-$(BOARD_SUB)
    endif
    $(call show_config_variable,OBJDIR,[COMPUTED],(from BOARD_TAG))
else
    $(call show_config_variable,OBJDIR,[USER])
endif

# Now that we have ARDUINO_DIR, ARDMK_VENDOR, ARCHITECTURE and CORE,
# we can set ARDUINO_CORE_PATH.
ifndef ARDUINO_CORE_PATH
    ifeq ($(strip $(CORE)),)
        ARDUINO_CORE_PATH = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/cores/arduino
        $(call show_config_variable,ARDUINO_CORE_PATH,[DEFAULT])
    else
        ARDUINO_CORE_PATH = $(ALTERNATE_CORE_PATH)/cores/$(CORE)
        ifeq ($(wildcard $(ARDUINO_CORE_PATH)),)
            ARDUINO_CORE_PATH = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/cores/$(CORE)
            $(call show_config_variable,ARDUINO_CORE_PATH,[COMPUTED],(from ARDUINO_DIR, BOARD_TAG and boards.txt))
        else
            $(call show_config_variable,ARDUINO_CORE_PATH,[COMPUTED],(from ALTERNATE_CORE_PATH, BOARD_TAG and boards.txt))
        endif
    endif
else
    $(call show_config_variable,ARDUINO_CORE_PATH,[USER])
endif

