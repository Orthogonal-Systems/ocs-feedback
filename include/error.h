#ifndef ERROR_H
#define ERROR_H

#include <stdint.h>
#include "feedback_conf.h"
#include "utility.h"

//! Error computation and statistics handling
/*!
 * Calculates errors and error statistics
 */
class Error {
  private:
    static const uint8_t i_chs = I_CHANNELS;  //!< input channels 
    static const uint8_t e_chs = O_CHANNELS;  //!< input channels 
    uint16_t channel_mask;                    //!< enabled channels, bitwise
    int16_t references[i_chs];                //!< channel setpoints
    errors_t errors;                    

    int16_t error_in[i_chs];                  //!< stores last error calculation from inputs
    int16_t error_in_mean[i_chs];             //!< stores mean error calculation from inputs
    uint16_t error_in_var[i_chs];             //!< stores error variance from inputs
    uint16_t smoothing_factor[i_chs];         //!< discrete time rc-factor

    int8_t error_matrix[e_chs][i_chs];        //!< handles coupled inputs

  public: 
    //! Class constructor
    /*!
     * \param _channels is the number of available input channels
     */
    Error();

    //! return the reference points
    int16_t* GetReferences(){ return references; };

    //! change the references for each channel
    void   SetReferences( int16_t *_references );

    //! get the last errors, dont refresh
    /*!
     * \return pointer to last_errors data array
     */
    int16_t* GetPErrors(){ return errors.error_P; };

    //! get the last errors, dont refresh
    /*!
     * \return pointer to last_errors data array
     */
    int16_t* GetIErrors(){ return errors.error_I; };

    //! get the last errors, dont refresh
    /*!
     * \return pointer to last_errors data array
     */
    int16_t* GetDErrors(){ return errors.error_D; };

    //! get the last errors, dont refresh
    /*!
     * \return pointer to error struct
     */
    errors_t GetErrors(){ return errors; };

    //! calculate new error values from inputs
    /*!
      * \param i_vals holds input values from each channel
      * \param deltaT holds time in us since last error reading (for calculating freq)
      * \return newest error value
      *
      * calculates PID errors, means, and variance values
      */
    errors_t CalculateErrors( int16_t *i_vals, uint16_t deltaT_us );

    //! get the mean error values
    /*!
     * \return channel error means
     */
    int16_t* GetErrorMean(){ return error_in_mean; };

    //! get the rms error values
    /*!
     * \return channel error rms
     */
    uint16_t* GetErrorVariance(){ return error_in_var; };

    //! set the smoothing factors
    /*!
     *  \param sf point to smoothing factor array
     *
     *  sets the smoothing facotr as a raw number, to set as time in ms(us) use:
     *  `SetTimeConst_us()` or `SetTimeConst_ms()`
     */
    void SetSmoothingFactor( uint16_t* sf ){
      for(uint8_t i=0; i<i_chs; i++){
        smoothing_factor[i] = sf[i];
      }
    }

    //! get the smoothing factors
    /*!
     *  \param sf smoothing factor
     *
     *  gets the smoothing facotr as a raw number, to get as time in ms(us) use:
     *  `GetTimeConst_us()` or `GetTimeConst_ms()`
     */
    uint16_t* GetSmoothingFactor(){
      return smoothing_factor;
    }

    //! set the smoothing factors
    /*!
     *  \param channel number
     *  \param sf smoothing factor for channel n
     *
     *  sets the smoothing facotr as a raw number, to set as time in ms(us) use:
     *  `SetChTimeConst_us()` or `SetChTimeConst_ms()`
     */
    void SetChSmoothingFactor( uint8_t n, uint16_t sf ){
      if ( n < i_chs ){
        smoothing_factor[n] = sf;
      }
    }

    //! get the smoothing factors
    /*!
     *  \param sf smoothing factor
     *
     *  gets the smoothing facotr as a raw number, to get as time in ms(us) use:
     *  `GetChTimeConst_us()` or `GetChTimeConst_ms()`
     */
    uint16_t GetChSmoothingFactor( uint8_t n ){
      return smoothing_factor[n];
    }

    //! set the smoothing factors in terms of the time constant in ms
    /*!
     * \param rc is the rc time constant in ms
     * \return computed smoothing factors
     */
    uint16_t* SetTimeConst_ms( uint16_t* rc ){
      for( uint8_t i = 0; i<i_chs; i++ ){
        smoothing_factor[i] = (uint16_t)((((uint32_t)rc[i]<<16)/(0xFFFF - rc[i]))>>16);
      }
      return smoothing_factor;
    }

    //! set the smoothing factor in terms of the time constant in ms
    /*!
     * \param rc is the rc time constant in ms
     * \return computed smoothing factors
     */
    uint16_t SetChTimeConst_ms( uint8_t n, uint16_t rc ){
      SetChSmoothingFactor(n, rc/(0xFFFF - rc));
      return smoothing_factor[n];
    }

    //! set the smoothing factor in terms of the time constant in ms
    /*!
     * \param n is the channel number
     * \return computed smoothing factors
     */
    uint16_t GetChTimeConst_ms( uint8_t n ){
      return (uint16_t)(smoothing_factor[n]/(0xFFFF + smoothing_factor[n]));
    }

    //! Set pointer to error matrix
    /*! 
     * \param tm pointer to error matrix
     *
     */
    void SetErrorMatrix( int8_t** em );

    //! Get pointer to error matrix
    /*!
     * Get a pointer to the transer matrix
     */
//    uint8_t** GetErrorMatrix(){
//      return error_matrix;
//    }

    //! Set index of error matrix
    /*!
     *  \param row denotes the desired index row
     *  \param col denotes the desired index column
     *  \param val value to be stored
     */
    void SetErrorMatrixEntry( uint8_t row, uint8_t col, uint8_t val ){
      error_matrix[row][col] = val;
    }

    //! Get index of error matrix
    /*!
     *  \param row denotes the desired index row
     *  \param col denotes the desired index column
     */
    uint8_t GetErrorMatrixEntry( uint8_t row, uint8_t col ){
      return error_matrix[row][col];
    }
};

#endif
