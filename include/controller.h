#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <stdint.h>
#include "feedback_conf.h"
#include "utility.h"

//! Feedback controller, computes next output given current/past errors
class Controller {
  private:
    static const uint8_t o_channels = O_CHANNELS;  //!< output channel length
    int16_t output[o_channels];     //!< the next value written to the outputs
    int16_t weights[o_channels][3]; //!< controller gain, [ kp[n], ki[n], kd[n] ]

    void init( int16_t* init_output );

  public:
    Controller();
    Controller( int16_t* init_output );

    //! Calculate the next output value based on the
    /*!
     * \param errors pointer to current error value
     * \return errors code, 0 for no error
     */
    uint8_t CalcNextValue( errors_t errors );

    //! Get the next value to push to the output
    /*!
     * \return next vlue to push to the output
     */
    int16_t* GetNextValue(){ return output; };

    //! Resets all feedback memory
    /*!
     * \param val to write to the stored last values
     *
     * Override the last_output value stored and clear history.
     * It is necessary to initialize to a reasonable output
     */
    void Reset( int16_t* val );

    //void Flush(); // is this necessary?

    //! Return the number of available output channels
    /*!
     * \return number of output channels availble on the device
     */
    const uint8_t GetOChannels(){ return o_channels; };

};

#endif
