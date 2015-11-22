########################################################################
# Serial monitor (just a screen wrapper)

# Quite how to construct the monitor command seems intimately tied
# to the command we're using (here screen). So, read the screen docs
# for more information (search for 'character special device').

ifeq ($(strip $(NO_CORE)),)
    ifndef MONITOR_BAUDRATE
        ifeq ($(words $(LOCAL_PDE_SRCS) $(LOCAL_INO_SRCS)), 1)
            SPEED = $(shell egrep -h 'Serial.begin *\([0-9]+\)' $(LOCAL_PDE_SRCS) $(LOCAL_INO_SRCS) | sed -e 's/[^0-9]//g'| head -n1)
            MONITOR_BAUDRATE = $(findstring $(SPEED),300 1200 2400 4800 9600 14400 19200 28800 38400 57600 115200)
        endif

        ifeq ($(MONITOR_BAUDRATE),)
            MONITOR_BAUDRATE = 9600
            $(call show_config_variable,MONITOR_BAUDRATE,[ASSUMED])
        else
            $(call show_config_variable,MONITOR_BAUDRATE,[DETECTED], (in sketch))
        endif
    else
        $(call show_config_variable,MONITOR_BAUDRATE, [USER])
    endif

    ifndef MONITOR_CMD
        MONITOR_CMD = screen
    endif
endif
