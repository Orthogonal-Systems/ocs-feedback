# ocs-base
Base repository structure for open control systems (OCS) projects.

Arduino libraries are from 1.0.5 branch since >1.0 is mostly centered around expanding hardware support.

## How To Use

### You

Just fork the repo as normal, remove/add libraries, write code, etc.
Each library needs a CMakeLists.txt file in the top level of the library, and if applicable also in the {library_dir}/examples/ directory as well.
See amc7812 for an example directory structure.
Of course, you can structure your libraries however you want, but that will need to be reflected in the CMakeLists.txt files.

### Me

github doesn't allow you to fork your own repo, so to make a new project that derives from this one I need to:

 * Create an empty repo on github with the desired project name, no readme/license etc.

```Bash
$ git clone https://github.com/orthogonal-systems/ocs-myproject
$ cd ocs-project
$ git remote add upstream https://github.com/Orthogonal-Systems/ocs-base.git 
$ git pull upstream master
```
 * make your initial changes, edit readme, add/remove libraries, whatever

```Bash
$ git submodule update --init --recursive
$ git commit -m "inital commit"
$ git push origin master
```

Changes to ocs-base can be applied by merging with:

```Bash
$ git pull upstream master
```

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
