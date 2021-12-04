/*
 * threads.cpp
 *
 *  Created on: Dec 3, 2021
 *      Author: benja
 */
#include "threads.h"
#include <albertOS.h>
#include "main.h"
#include "midi.h"
#include "uart.h"

// Private namespace
namespace {

albertOS::FIFO<uint16_t, 16> midi_uart_FIFO; // used to be 64
albertOS::FIFO<midi::MIDINote, 64> note_FIFO;

} // end of private namespace

////////////////////////////////////////////////////////////////
// Threads
////////////////////////////////////////////////////////////////

void blink_led() {
    // Set up onboard LED
    GPIO_setAsOutputPin(GPIO_PORT_P1, LED_ONBOARD);
    GPIO_setOutputLowOnPin(GPIO_PORT_P1, LED_ONBOARD);

    while(true) {
        GPIO_toggleOutputOnPin(GPIO_PORT_P1, LED_ONBOARD);
        albertOS::sleep(500);
    }
} // end of thread

void decode_midi() {
    using namespace midi;

    // State used for parsing.
    decodeState state = COMMAND;

    // Wait until FIFO is full.
//    while(!midi_uart_FIFO.full()) {
//        albertOS::sleep(100);
//    }

    while(true) {
        MIDINote note;

        // Wait for the next MIDI byte from the UART.
        const auto byte = midi_uart_FIFO.read();

        if(state == COMMAND) {
            if(byte == NOTE_ON) {
                state = PITCH;
                uart::threadBackChannelPrint("Note ON", BackChannel_Warning);
            }
//            else if(byte == NOTE_OFF) {} // This shouldn't happen I don't think
            else {
                char msg[32];
                sprintf(msg, "Invalid command: 0x%02X", byte);
                uart::threadBackChannelPrint(msg, BackChannel_Warning);
            }
        }
        else if(state == PITCH) {
            note.pitch = byte;
            state = VELOCITY;
        }
        else if(state == VELOCITY) {
            note.velocity = byte;
            // The note is constructed! Add to FIFO.
            note_FIFO.write(note);

            // TODO remove, debug print note
            char msg[64];
            sprintf(msg, "note: pitch=0x%02X, vel=0x%02X", note.pitch, note.velocity);
            uart::threadBackChannelPrint(msg, BackChannel_Info);

            state = COMMAND;
        }
    }
} // end of thread

#if MIDI_MOCK_NOTES
void send_mock_notes() {

    uint16_t noteON[] = {0x90, 0x3c, 0x7b}; // note on, 60, 123
    uint16_t noteOFF[] = {0x90, 0x3c, 0x0}; // note on + vel 0 = note off

    while(true) {
        // Send a "fake" note via the FIFO.
        // Other threads will think it came from the UART.

        for(const auto byte: noteON) {
            midi_uart_FIFO.write(byte);
        }

        albertOS::sleep(500);

        for(const auto byte: noteOFF) {
            midi_uart_FIFO.write(byte);
        }

        albertOS::sleep(500);
    }
}
#endif

////////////////////////////////////////////////////////////////
// Events
////////////////////////////////////////////////////////////////

void midi_rx_isr() {
    const auto value = UCA1RXBUF;
    // Ignore ActiveSensing signals.
    if(value != midi::ACTIVE_SENSING) {
        midi_uart_FIFO.write(value);
    }
}

