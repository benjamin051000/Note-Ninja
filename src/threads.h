/*
 * threads.h
 *
 *  Created on: Dec 3, 2021
 *      Author: benja
 */
#pragma once
#include "main.h"

// Threads
void blink_led();

// Events
void midi_rx_isr();

void decode_midi();

#if MIDI_MOCK_NOTES
void send_mock_notes();
#endif
