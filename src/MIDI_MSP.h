/*
 * MIDI_MSP.h
 *
 *  Created on: Nov 10, 2021
 *      Author: benja
 */

#ifndef SRC_MIDI_MSP_H_
#define SRC_MIDI_MSP_H_
#include "MIDI.h"

/**
 * MSPSerial
 * Serial interface for the MSP432.
 * Utilizes RX of eUSCI UART A1 (P2.2)
 * to read incoming MIDI UART data.
 *
 * To be compatible with the Arduino MIDI
 * library, this is represented as a subset
 * of an Arduino-compliant Serial class.
 */
class MSPSerial {
public:
    /**
     * Initialize Serial interface.
     */
    void begin(long baudRate);

    /**
     * Destroy Serial connection
     * (Note: Unused)
     */
    void end();

    /**
     * Write UART Data.
     * (Note: Unused)
     */
    void write(byte value);

    /**
     * Read a byte of data from the RX Buffer.
     */
    byte read();

    /**
     * Check if UART is available.
     * (Note: Always returns true, which may be bad)
     */
    unsigned available();
};


#endif /* SRC_MIDI_MSP_H_ */
