#ifndef FEEDBACK_CONF
#define FEEDBACK_CONF

#define I_CHANNELS 1//16                   //!< input channels to be used, can save RAM in error matrix
#define O_CHANNELS 1//12                   //!< output channels to be used, can save RAM in error matrix
#define FEEDBACK_ERROR_BOUND 0x7FFF     //!< abs maximum value for error data, (2**15)-1
#define FEEDBACK_OUTPUT_U_BOUND 0x0FFF  //!< abs maximum value for output, 12b
#define FEEDBACK_OUTPUT_L_BOUND 0       //!< abs minimum value for output, 
#define FEEDBACK_MAX_AVGS 8             //!< averages = (1<<FEEDBACK_MAX_AVGS)

#endif
