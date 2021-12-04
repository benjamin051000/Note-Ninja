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
 * Initialize backchannel UART (via port1 pin 2) with a 3MHz SMCLK, 115200 baud.
 */
void back_channel_init();

/**
 * Uses a mutex to print to the backchannel UART in a thread-safe way.
 */
void threadBackChannelPrint(const char* str, BackChannelTextStyle_t style);

} // end of namespace UART
