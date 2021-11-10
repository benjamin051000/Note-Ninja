/*
 * MIDI_MSP.h
 *
 *  Created on: Nov 10, 2021
 *      Author: benja
 */

#ifndef SRC_MIDI_MSP_H_
#define SRC_MIDI_MSP_H_
#include "MIDI.h"
//#include "midi_Defs.h"

void create_midi_instance();


class MSPSerial {
public:
    void begin(long baudRate);
    void end();
    void write(byte value);
    byte read();
    unsigned available();
};


#endif /* SRC_MIDI_MSP_H_ */
