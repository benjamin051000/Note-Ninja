/*
 * midi.h
 *
 *  Created on: Dec 3, 2021
 *      Author: benja
 */
#pragma once
#include <stdint.h>

namespace midi {

/**
 * Initialize MIDI UART input interface.
 */
void init();

const int NOTE_ON = 0x90;
const int NOTE_OFF = 0x80;
const int ACTIVE_SENSING = 0xFE;
const int CHANNEL_PRESSURE = 0xD0;

enum decodeState {
    CHANNEL,
    COMMAND,
    PITCH,
    VELOCITY
};

struct MIDINote {
    uint8_t pitch, velocity;
};

} // end of namespace midi
