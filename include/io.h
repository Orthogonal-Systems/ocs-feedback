#ifndef IO_H
#define IO_H

#include "amc7812.h"
#include <stdint.h>
#include "feedback_conf.h"

////////////////////////////////////////////////////////////////////////////////
// status values
#define IO_STATUS_OK    0x00  // nominal
#define IO_STATUS_NC    0x01  // not connected to device
#define IO_STATUS_FATAL 0xff  // fatal error occured


////////////////////////////////////////////////////////////////////////////////
//! Wrapper class for input/output device
/*!
 *  This IO device wrapper class is spefically for the AMC7812 device.
 *
 *  In this instance the Input and Output devices are the same chip,
 *  so they are combined in the same member class io
 */
class IO {
  private:
    AMC7812Class amc7812;                     //!< input/output driver class
    static const uint8_t i_channels = O_CHANNELS; //!< number of input channels available
    static const uint8_t o_channels = I_CHANNELS; //!< number of output channels available
    uint16_t i_ch_mask;                       //!< enabled input channels, bitwise
    uint16_t o_ch_mask;                       //!< enabled output channels, bitwise
    int16_t i_vals[i_channels];               //!< result of last channel reads
    int16_t o_vals[o_channels];               //!< result of last channel reads
    uint8_t status;                           //!< device status register
    uint16_t last_call_us;                    //!< timestamp from last read, in microseconds
    uint16_t deltaT_us;                           //!< elasped time between last two reads, in microseconds

    //! generate bit mask for 

  public:
    //! class constructor
    /*!
     * Constructor sets class fields, does not begin communication with device,
     * to do that `Init()` must be called after.
     */
    IO(){
      status = IO_STATUS_NC;
    };

    //! Initiaizes driver and device to prepare for feedback.
    /*!
     * \return 0 for success, non-zero for error
     */
    // TODO: add setting/options
    uint8_t Init();

    //! Perform a read operation, updating i_vals data array
    /*!
     * \return error code, 0 is no error
     *
     * Read enabled input channels from device, a pointer to the array is
     * returned.
     * Value of non-enabled channels is not defined at this level, check the driver.
     */
    int8_t ReadInputs();

    //! Get the last read values, don't update
    /*!
     * \return pointer to i_vals data array
     *
     * Get last read value from inputs, but don't update the reads.
     */
    int16_t* GetLastInputs(){ return i_vals; };

    //! Return the number of available input channels
    /*!
     * \return number of input channels availble on the device
     */
    const uint8_t GetAvailableIChannels(){ return i_channels; };

    //! Set the bitwise input channel enabled mask and update device
    /*!
     * Enabled channels are denoted by a 1 in the corresponding bit.
     */
    void SetEnabledIChannels( uint16_t mask );

    //! Return the bitwise input channel enabled mask
    /*!
     * \return the bitwise input channel enabled mask
     *
     * Enabled channels are denoted by a 1 in the corresponding bit.
     */
    uint16_t GetEnabledIChannels(){ return i_ch_mask; };

    //! Perform a write operation to the output device
    /*!
     * \param vals is the updated output setpoints
     *
     * dac is not updated until `UpdateDac()` is called
     */
    void SetOutputs( int16_t* vals );

    //! Get the last set of values written to the output device
    /*!
     * \return pointer to the last set of values written to the output device
     */
    int16_t* GetOutputs(){ return o_vals; };

    //! Get the last output values
    /*!
     * \return pointer to o_vals data array
     *
     * Get last read value from inputs, but don't update the reads.
     */
    int16_t* GetLastOutputs(){ return o_vals; };

    //! Return the number of available output channels
    /*!
     * \return number of output channels availble on the device
     */
    const uint8_t GetAvailableOChannels(){ return o_channels; };

    //! Set the bitwise output channel enabled mask and update device
    /*!
     * Enabled channels are denoted by a 1 in the corresponding bit.
     */
    void SetEnabledOChannels( uint16_t mask );

    //! Return the bitwise output channel enabled mask
    /*!
     * \return the bitwise output channel enabled mask
     *
     * Enabled channels are denoted by a 1 in the corresponding bit.
     */
    uint16_t GetEnabledOChannels(){ return o_ch_mask; };

    //! Simultaneously update all DAC Channels
    void UpdateDAC(){
      amc7812.UpdateDAC();
    }

    uint16_t GetDeltaT_us(){ return deltaT_us; };
};

#endif
