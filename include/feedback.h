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
    uint8_t averages;  //!< default number of averages to perform in measurements

    //! called in constructor
    void init( uint8_t avgs );

  public:
    IO          io;
    Error       err;
    Controller  ctrl;
    WatchDog    wd;

    //! constructor
    /*!
     * \param avgs sets the default number of averages to be performed 2**n,
     * (default 2**0 = 1)
     */
    Feedback();
    Feedback( uint8_t avgs );

    //! Initialize the member classes
    uint8_t IOInit();
    
    //! Measure the system 2**`average` times and compute next output value
    uint8_t Measure();

    //! Measure the system 2**n times and compute next output value
    uint8_t Measure( uint8_t n );

    //! Push output values
    void Update();

    //! Sets the number of averages to perform
    /*!
     * \param 2**n averges to be set, n max = FEEDBACK_MAX_AVGS
     * \return the set value of averages, incase the set value was overriden
     *
     * Sets the default number of averages to be made during a measurement operation.
     * 2**n with n max = `FEEDBACK_MAX_AVGS`
     */
    uint8_t SetAverages( uint8_t n );
};

#endif
