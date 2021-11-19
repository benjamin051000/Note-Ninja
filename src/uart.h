#ifndef MYUART_H_
#define MYUART_H_

#include <stdint.h>

namespace UART
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
void midi_uart_2_init();

/**
 * Initialize backchannel UART (via port1 pin 2 (?)) with a 3MHz SMCLK, 115200 baud.
 */
void back_channel_pcb_init();

} // end of namespace UART

#endif
