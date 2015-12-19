#ifndef FEEDBACK_H
#define FEEDBACK_H

#include <stdint.h>
#include "feedback_conf.h"
#include "io.h"
#include "error.h"
#include "controller.h"

//! Functions to make sure errors are not diverging
class WatchDog {
  public:
    uint8_t IsOK(){ return true; };
};

//! Top-level feedback class
class Feedback {
  private:
    static const uint8_t i_channels = I_CHANNELS;
    static const uint8_t o_channels = O_CHANNELS;

  public:
    IO          io;
    Error       err;
    Controller  ctrl;
    WatchDog    wd;

    //! constructor
    Feedback();

    //! Initialize the member classes
    uint8_t Init();
    
    //! Measure the system and compute next output value
    uint8_t Measure();

    //! Push output values
    void Update();
};

#endif
