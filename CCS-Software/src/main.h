/*
 * main.h
 *
 *  Created on: Nov 19, 2021
 *      Author: benja
 *
 *      Holds some useful #define constants that are used universally around the project.
 */
#pragma once

/**
 * Use these defines to ensure
 * the proper I/O/UART Baud/Clock structure
 * is selected when setting up the target.
 * To test the Launchpad, comment out the
 * define statement below.
 */
#define TARGET_PCB 1

/**
 * Instead of using real MIDI data,
 * create mock notes to ensure
 * the threads to decode and send the data
 * work properly.
 */
#define MIDI_MOCK_NOTES 0

// Constants for the LED blink demo.
#if TARGET_PCB
#define LED_ONBOARD GPIO_PIN7 // For PCB blue LED
#else
#define LED_ONBOARD GPIO_PIN0 // For launchpad red LED
#endif
