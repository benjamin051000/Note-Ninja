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

void test_uart_to_fpga();

void advance_notes();

void send_song();

void check_for_note();

#if MIDI_MOCK_NOTES
void send_mock_notes();
#endif
