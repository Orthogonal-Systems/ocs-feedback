#ifndef ERROR_H
#define ERROR_H

#include <stdint.h>
#include "feedback_conf.h"

//! Error computation and statistics handling
/*!
 * Calculates errors and error statistics
 */
class Error {
  private:
    static const uint8_t chs = I_CHANNELS; //!< input channels 
    uint16_t channel_mask;                //!< enabled channels, bitwise
    int16_t references[chs];             //!< channel setpoints
    int16_t last_errors[chs];            //!< stores last error calculation
    int16_t error_mean[chs];             //!< stores mean errors
    uint16_t error_rms[chs];              //!< stores rms errors
    uint16_t smoothing_factor[chs];       //!< discrete time rc-factor

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
    int16_t* GetErrors(){ return last_errors; };

    //! calculate new error values from inputs
    /*!
     * \param i_vals holds input values from each channel
     * \return newest error value
     *
     * calculates errors, means, and rms values
     */
    int16_t* CalculateErrors( int16_t *i_vals );

    //! get the mean error values
    /*!
     * \return channel error means
     */
    int16_t* GetErrorMean(){ return error_mean; };

    //! get the rms error values
    /*!
     * \return channel error rms
     */
    uint16_t* GetErrorRMS(){ return error_rms; };

    //! get the number of available input channels
    /*!
     * \return available input channels
     */
    const uint8_t GetChannels(){ return chs; };

    //! set the smoothing factors
    /*!
     *  \param sf point to smoothing factor array
     *
     *  sets the smoothing facotr as a raw number, to set as time in ms(us) use:
     *  `SetTimeConst_us()` or `SetTimeConst_ms()`
     */
    void SetSmoothingFactor( uint16_t* sf ){
      for(uint8_t i=0; i<chs; i++){
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
      if ( n < chs ){
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
      for( uint8_t i = 0; i<chs; i++ ){
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
};

#endif
