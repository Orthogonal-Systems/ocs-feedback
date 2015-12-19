#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <stdint.h>
#include <feedback_conf.h>

//! Feedback controller, computes next output given current/past errors
class Controller {
    static const uint8_t i_channels = I_CHANNELS;  //!< input channel length
    static const uint8_t o_channels = O_CHANNELS;  //!< output channel length
    int8_t transfer_matrix[o_channels][i_channels];  //!< transfer matrix
    int16_t last_output[o_channels];  //!< the last value written to the outputs
    int16_t new_output[o_channels];   //!< the next value written to the outputs

  public:
    Controller();

    //! Calculate the next output value based on the
    /*!
     * \param errors pointer to current error value
     * \return errors code, 0 for no error
     */
    uint8_t CalcNextValue( int16_t* errors );

    //! Get the next value to push to the output
    /*!
     * \return next vlue to push to the output
     */
    int16_t* GetNextValue(){ return new_output; };

    //! Resets all feedback memory
    /*!
     * \param val to write to the stored last values
     *
     * Override the last_output value stored and clear history.
     * It is necessary to initialize to a reasonable output
     */
    void Reset( int16_t* val );
    //void Flush(); // is this necessary?

    //! Return the number of available input channels
    /*!
     * \return number of input channels availble on the device
     */
    const uint8_t GetIChannels(){ return i_channels; };

    //! Return the number of available output channels
    /*!
     * \return number of output channels availble on the device
     */
    const uint8_t GetOChannels(){ return o_channels; };

    //! Set pointer to transfer matrix
    /*! 
     * \param tm pointer to transfer matrix
     *
     */
    void SetTransferMatrix( int8_t** tm );

    //! Get pointer to transfer matrix
    /*!
     * Get a pointer to the transer matrix
     */
//    uint8_t** GetTransferMatrix(){
//      return transfer_matrix;
//    }

    //! Set index of transfer matrix
    /*!
     *  \param row denotes the desired index row
     *  \param col denotes the desired index column
     *  \param val value to be stored
     */
    void SetTransferMatrixEntry( uint8_t row, uint8_t col, uint8_t val ){
      transfer_matrix[row][col] = val;
    }

    //! Get index of transfer matrix
    /*!
     *  \param row denotes the desired index row
     *  \param col denotes the desired index column
     */
    uint8_t GetTransferMatrixEntry( uint8_t row, uint8_t col ){
      return transfer_matrix[row][col];
    }
};

#endif
