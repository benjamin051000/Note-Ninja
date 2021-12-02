/*
 * MIDI_MSP.h
 *
 *  Created on: Nov 10, 2021
 *      Author: benja
 */

#pragma once
#include "MIDI.h"

#define MIDI_CREATE_PCB_INSTANCE() \
    MSPSerial MSPSerialObj; \
    MIDI_CREATE_CUSTOM_INSTANCE(MSPSerial, MSPSerialObj, MIDI, MIDI_PCB_SETTINGS);


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

struct MIDI_PCB_SETTINGS : public midi::DefaultSettings {
    /*! Global switch to turn on/off receiver ActiveSensing
    Set to true to check for message timeouts (via ErrorCallback)
    Set to false will not check if chained device are still alive (if they use ActiveSensing) (will also save memory)
    */
    static const bool UseReceiverActiveSensing = true;
};
