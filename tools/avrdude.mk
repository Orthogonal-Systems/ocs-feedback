########################################################################
# Avrdude

# If avrdude is installed separately, it can find its own config file
ifndef AVRDUDE
    AVRDUDE          = $(AVR_TOOLS_PATH)/avrdude
endif

# Default avrdude options
# -V Do not verify
# -q - suppress progress output
ifndef AVRDUDE_OPTS
    AVRDUDE_OPTS = -q -V
endif

# Decouple the mcu between the compiler options (-mmcu) and the avrdude options (-p).
# This is needed to be able to compile for attiny84a but specify the upload mcu as attiny84.
# We default to picking the -mmcu flag, but you can override this by setting
# AVRDUDE_MCU in your makefile.
ifndef AVRDUDE_MCU
  AVRDUDE_MCU = $(MCU)
endif

AVRDUDE_COM_OPTS = $(AVRDUDE_OPTS) -p $(AVRDUDE_MCU)
ifdef AVRDUDE_CONF
    AVRDUDE_COM_OPTS += -C $(AVRDUDE_CONF)
endif

# -D - Disable auto erase for flash memory
# Note: -D is needed for Mega boards.
#       (See https://github.com/sudar/Arduino-Makefile/issues/114#issuecomment-25011005)
AVRDUDE_ARD_OPTS = -D -c $(AVRDUDE_ARD_PROGRAMMER) -b $(AVRDUDE_ARD_BAUDRATE) -P
ifeq ($(CURRENT_OS), WINDOWS)
    # get_monitor_port checks to see if the monitor port exists, assuming it is
    # a file. In Windows, avrdude needs the port in the format 'com1' which is
    # not a file, so we have to add the COM-style port directly.
    AVRDUDE_ARD_OPTS += $(COM_STYLE_MONITOR_PORT)
else
    AVRDUDE_ARD_OPTS += $(call get_monitor_port)
endif

ifndef ISP_PROG
    ifneq ($(strip $(AVRDUDE_ARD_PROGRAMMER)),)
        ISP_PROG = $(AVRDUDE_ARD_PROGRAMMER)
    else
        ISP_PROG = stk500v1
    endif
endif

ifndef AVRDUDE_ISP_BAUDRATE
    ifneq ($(strip $(AVRDUDE_ARD_BAUDRATE)),)
        AVRDUDE_ISP_BAUDRATE = $(AVRDUDE_ARD_BAUDRATE)
    else
        AVRDUDE_ISP_BAUDRATE = 19200
    endif
endif

# Fuse settings copied from Arduino IDE.
# https://github.com/arduino/Arduino/blob/master/app/src/processing/app/debug/AvrdudeUploader.java#L254

# Pre fuse settings
ifndef AVRDUDE_ISP_FUSES_PRE
    ifneq ($(strip $(ISP_LOCK_FUSE_PRE)),)
        AVRDUDE_ISP_FUSES_PRE += -U lock:w:$(ISP_LOCK_FUSE_PRE):m
    endif

    ifneq ($(strip $(ISP_EXT_FUSE)),)
        AVRDUDE_ISP_FUSES_PRE += -U efuse:w:$(ISP_EXT_FUSE):m
    endif

    ifneq ($(strip $(ISP_HIGH_FUSE)),)
        AVRDUDE_ISP_FUSES_PRE += -U hfuse:w:$(ISP_HIGH_FUSE):m
    endif

    ifneq ($(strip $(ISP_LOW_FUSE)),)
        AVRDUDE_ISP_FUSES_PRE += -U lfuse:w:$(ISP_LOW_FUSE):m
    endif
endif

# Bootloader file settings
ifndef AVRDUDE_ISP_BURN_BOOTLOADER
    ifneq ($(strip $(BOOTLOADER_PATH)),)
        ifneq ($(strip $(BOOTLOADER_FILE)),)
            AVRDUDE_ISP_BURN_BOOTLOADER += -U flash:w:$(BOOTLOADER_PARENT)/$(BOOTLOADER_PATH)/$(BOOTLOADER_FILE):i
        endif
    endif
endif

# Post fuse settings
ifndef AVRDUDE_ISP_FUSES_POST
    ifneq ($(strip $(ISP_LOCK_FUSE_POST)),)
        AVRDUDE_ISP_FUSES_POST += -U lock:w:$(ISP_LOCK_FUSE_POST):m
    endif
endif

# Note: setting -D to disable flash erase before programming may cause issues
# with some boards like attiny84a, making the program not "take",
# so we do not set it by default.
AVRDUDE_ISP_OPTS = -c $(ISP_PROG) -b $(AVRDUDE_ISP_BAUDRATE)

ifndef $(ISP_PORT)
    ifneq ($(strip $(ISP_PROG)),$(filter $(ISP_PROG), usbasp usbtiny gpio linuxgpio avrispmkii dragon_isp dragon_dw))
        AVRDUDE_ISP_OPTS += -P $(call get_isp_port)
    endif
else
	AVRDUDE_ISP_OPTS += -P $(call get_isp_port)
endif

ifndef ISP_EEPROM
    ISP_EEPROM  = 0
endif

AVRDUDE_UPLOAD_HEX = -U flash:w:$(TARGET_HEX):i
AVRDUDE_UPLOAD_EEP = -U eeprom:w:$(TARGET_EEP):i
AVRDUDE_ISPLOAD_OPTS = $(AVRDUDE_UPLOAD_HEX)

ifneq ($(ISP_EEPROM), 0)
    AVRDUDE_ISPLOAD_OPTS += $(AVRDUDE_UPLOAD_EEP)
endif
