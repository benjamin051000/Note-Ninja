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

albertOS::FIFO<uint16_t, 64> midi_uart_FIFO; // used to be 64
albertOS::FIFO<midi::MIDINote, 64> note_FIFO;

//midi::MIDINote note;

const int note_arr_size = 5;
uart::FPGACommand notes[note_arr_size] = {
    uart::FPGACommand::CREATE_C,
    uart::FPGACommand::CREATE_HIGH_D,
    uart::FPGACommand::CREATE_HIGH_E,
    uart::FPGACommand::CREATE_HIGH_F,
    uart::FPGACommand::CREATE_HIGH_G
};

int note_positions[note_arr_size];

unsigned note_index;

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

    while(true) {
        MIDINote note;

        // Wait for the next MIDI byte from the UART.
        const auto byte = midi_uart_FIFO.read();

        if(state == COMMAND) {
            if(byte == NOTE_ON) {
                state = PITCH;
            }
            else if(byte == NOTE_OFF) { // Ryan's keyboard uses note off
                state = PITCH;
            }
            else {
                albertOS::addThread(blink_led, 1, (char*)"blink led");

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

            state = COMMAND;
        }

        albertOS::sleep(5);
    }
} // end of thread

#if MIDI_MOCK_NOTES
void send_mock_notes() {

    uint16_t noteON[] = {midi::NOTE_ON, 0x3c, 0x7b}; // note on, 60, 123
    uint16_t noteOFF[] = {midi::NOTE_OFF, 0x3c, 0x0}; // note on + vel 0 = note off

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


void test_uart_to_fpga() {
    using uart::FPGACommand;

    while(true) {
        // Send Cmaj scale

        for(unsigned cmd = (unsigned)FPGACommand::CREATE_LOW_D; cmd <= (unsigned)FPGACommand::CREATE_HIGH_G; cmd++) {

            uart::send_fpga_command((FPGACommand)cmd);

            // Advance the new note a little bit before making the next one.
            for(unsigned i = 0; i < 75; i++) {
                uart::send_fpga_command(FPGACommand::ADVANCE_NOTES);
                albertOS::sleep(15);
            }
        }

        // All the notes are made. Just wait for them to expire and go again
        for(unsigned i = 0; i < 100; i++) {
            uart::send_fpga_command(FPGACommand::ADVANCE_NOTES);
            albertOS::sleep(15);
        }

    } // end of while(true)

} // end of thread

// Send song notes one by one. Note advancement happens elsewhere.
void send_song() {
    while(true) {

        for(note_index = 0; note_index < note_arr_size; note_index++) {
            const auto note = notes[note_index];
            uart::send_fpga_command(note);

            note_positions[note_index] = 640;

            // 640/2 Advances later, you better play it
            albertOS::sleep(15 * 100); // Spawn next note when prev note moved approx 75
        }

        albertOS::sleep(3000); // wait 3 seconds before restarting song
    } // end of while(true)
}

// Advance notes at a constant rate.
void advance_notes() {
    using namespace uart;

//    const auto dist_to_vert_bar = 640/2;

    while(true) {
        // Advance the new note a little bit before making the next one.
//        for(unsigned i = 0; i < dist_to_vert_bar; i++) {
            send_fpga_command(FPGACommand::ADVANCE_NOTES);

            for(unsigned i = 0; i < note_arr_size; i++) {
                note_positions[i] -= 1; // Move each one to the left
            }

            albertOS::sleep(15);
//        }
    }
}

void check_for_note() {
    // check for note every 320 moves! Add some leeway

    const auto window = 15; // moves on both sides you get (mult window*2*15ms move to get ms leeway)

    uint8_t guitar_note;

    while(true) {
        bool note_hit = false;

        // Get UART input
        guitar_note = UART_receiveData(EUSCI_A0_BASE);

        // Iterate through each note position.
        // If one of the notes is within the window, check if it's the same pitch.
        for(unsigned i = 0; i < note_arr_size; i++) {

            const int note = note_positions[i];

            if(note >= 320-window && note <= 320+window) {

                // Get pitch of this note
                const int correct_note = notes[i];

                // Did guitar play it?
                if(guitar_note == correct_note) {
                    note_hit = true;
                    break;
                }
            }
        }

        // Send add point cmd once
        if(note_hit) {
            uart::send_fpga_command(uart::FPGACommand::ADD_POINTS); // Send twice for DSP
            uart::send_fpga_command(uart::FPGACommand::ADD_POINTS);
        }

        // Wait for next note (they are spaced apart by 100 moves)
        albertOS::sleep(100);

    } // end of while(true)
}

////////////////////////////////////////////////////////////////
// Events
////////////////////////////////////////////////////////////////

void midi_rx_isr() {
    const auto value = UCA1RXBUF;
    // Ignore ActiveSensing signals and Channel Pressure.

    midi_uart_FIFO.write(value);
}

