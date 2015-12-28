#ifndef FEEDBACK_UTILITY_H
#define FEEDBACK_UTILITY_H

#include <stdint.h>
#include "feedback_conf.h" // for abs()

//! Container for passing all three error type around
/*!
 *
 */
struct errors_t {
  int16_t error_P[O_CHANNELS];  //!< stores most recent error calculation
  int16_t error_I[O_CHANNELS];  //!< stores integrated errors (with time constant)
  int16_t error_D[O_CHANNELS];  //!< stores dirivative errors
};

int16_t CheckRange( int32_t in, int16_t bound );
int16_t CheckRange( int32_t in, int16_t u_bound, int16_t l_bound );

#endif
