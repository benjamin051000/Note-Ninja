#pragma once
#include <stdio.h>
#include <stdint.h>
#include <bsp.h>

namespace uart
{

/**
 * Initialize MIDI 1 UART RX
 * on Port 2 pin 2.
 */
void midi_uart_1_init();

/**
 * Initialize MIDI 2 UART RX
 * on Port 3 pin 2.
 */
//void midi_uart_2_init();

/**
 * Initialize backchannel UART (via port1 pin 2 & 3) with 115200 baud.
 */
void init_port1();

void init_guitar();

/**
 * Uses a mutex to print to the backchannel UART in a thread-safe way.
 */
void threadBackChannelPrint(const char* str, BackChannelTextStyle_t style);

void thread_port1_send_str(const char* str);

/**
 * UART commands to send to the FPGA.
 */
enum FPGACommand {
    ADVANCE_NOTES = 0x41, // Starts at 0x41 ('A') and increments for each entry
    CREATE_LOW_D, // 'B'
    CREATE_LOW_E, // 'C'
    CREATE_LOW_F, // 'D'
    CREATE_LOW_G, // 'E'
    CREATE_A,     // 'F'
    CREATE_B,     // 'G'
    CREATE_C,     // 'H'
    CREATE_HIGH_D,// 'I'
    CREATE_HIGH_E,// 'J'
    CREATE_HIGH_F,// 'K'
    CREATE_HIGH_G,// 'L'

    NOTE_ON, // Send this, then send the pitch byte.
    ADD_POINTS
};


/**
 * Send a single byte command to the FPGA.
 */
void send_fpga_command(FPGACommand cmd);

} // end of namespace UART
