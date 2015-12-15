# ocs-base
Base repository structure for open control systems (OCS) projects.

Arduino libraries are from 1.0.5 branch since >1.0 is mostly centered around expanding hardware support.

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
$ git clone https://github.com/orthogonal-systems/ocs-base MyOCSProject
$ cd MyOCSProject
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
$ make blink-arduino
```

Edit top-level CMakeLists.txt file to have the correct output port: SET(AVR_UPLOADTOOL_PORT "/dev/[your port here]")

upload to uno (you can do this without the previous make statement)
```Bash
$ make upload_blink-arduino
```
A non-arduino version is also available:
```Bash
$ make upload_blink-avr
```

## Pinouts
Board pinouts are stored in "include/variants/{board_name}/".
If your application requires board specific macros (like pin definitions), it is recommended to also place your pinout header in the relevant variant directory.
See amc7812conf.h file from the included example library, for example.
