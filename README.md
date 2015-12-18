# ocs-feedback
Firmware for that implements a feedback loop with the amc7812 ADC & DAC chip.
The analog interface exposes 16 ADCs and 12 DACs.

A final hardware design is, as of yet, unfinished.

Derived from the ocs-base project.

## Dependancies
What I've run it with.  I need to improve this list.

 * make 3.81
 * cmake 2.8.12
 * avr-gcc (GCC) 4.8.2
 * avr-libc 1.8.0
 * avr-binutils
 * avrdude
 * arduino bootloader

## Setup
```Bash
$ git clone https://github.com/orthogonal-systems/ocs-feedback MyOCSFeedbackProject
$ cd MyOCSFeedbackProject
$ git submodule update --init --recursive
```

Build libraries
```Bash
$ cd build
$ cmake .. ; make
```

## Build & Upload to Uno
Build .elf and .hex files (stored in build/bin/)
```Bash
$ cd build
$ make amc7812_test
```

Edit top-level CMakeLists.txt file to have the correct output port: SET(AVR_UPLOADTOOL_PORT "/dev/[your port here]")

upload to mega (you can do this without the previous make statement)
```Bash
$ make upload_amc7812_test
```

## Pinouts
Board pinouts are stored in "include/variants/{board_name}/".
If your application requires board specific macros (like pin definitions), it is recommended to also place your pinout header in the relevant variant directory.
See amc7812conf.h file from the included example library, for example.
