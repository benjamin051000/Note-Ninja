#ifndef MYUART_H_
#define MYUART_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

/**
 * Initialize MIDI 1 UART RX
 * on Port 2 pin 2.
 */
void midi_uart_1_init(void);

/**
 * Initialize MIDI 2 UART RX
 * on Port 3 pin 2.
 */
void midi_uart_2_init(void);

/**
 * Initialize back channel UART with 31250 baud rate.
 * For testing purposes only. Generally, use BSP_InitBoard()
 * to automatically set up back channel UART at 112500.
 */
void back_channel_31250_init(void);


#ifdef __cplusplus
}
#endif

#endif
