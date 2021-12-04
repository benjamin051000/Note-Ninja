/*
 * midi.cpp
 *
 *  Created on: Dec 3, 2021
 *      Author: Benjamin Wheeler
 */
#include "midi.h"

#include <driverlib.h>
#include "main.h"

// Private namespace
namespace {
#if TARGET_PCB
/**
 * Config for a MIDI-compliant UART input at 31250 baud.
 * Uses a 3MHz SMCLK.
 */
const eUSCI_UART_Config UART_cfg_31250_3MHz = {
    EUSCI_A_UART_CLOCKSOURCE_SMCLK,
    6, // BRDIV
    0, // UCxBRF
    0, // UCxBRS
    EUSCI_A_UART_NO_PARITY,
    EUSCI_A_UART_LSB_FIRST,
    EUSCI_A_UART_ONE_STOP_BIT,
    EUSCI_A_UART_MODE, // UART mode
    EUSCI_A_UART_OVERSAMPLING_BAUDRATE_GENERATION // Oversampling
};
#else
/* Configuration for a MIDI-compatible UART at 31250 baud.
 * Uses a 12 MHz SMCLK.
 */
const eUSCI_UART_Config UART_cfg_31250_12MHz = {
    EUSCI_A_UART_CLOCKSOURCE_SMCLK,
    24, // BRDIV
    0,  // UCxBRF
    0,  // UCxBRS
    EUSCI_A_UART_NO_PARITY,
    EUSCI_A_UART_LSB_FIRST,
    EUSCI_A_UART_ONE_STOP_BIT,
    EUSCI_A_UART_MODE, // UART mode
    EUSCI_A_UART_OVERSAMPLING_BAUDRATE_GENERATION // Oversampling
};
#endif

} // end of private namespace
////////////////////////////////////////////////////////////////////////////

void midi::init() {
    // Select GPIO functionality
    // P2.2 is UART RX. We don't need TX because we are only receiving MIDI.
    MAP_GPIO_setAsPeripheralModuleFunctionInputPin(
            GPIO_PORT_P2,
            GPIO_PIN2,
            GPIO_PRIMARY_MODULE_FUNCTION
    );

    // Configure UART with 31250 baud rate
#if TARGET_PCB
    MAP_UART_initModule(EUSCI_A1_BASE, &UART_cfg_31250_3MHz);
#else
    MAP_UART_initModule(EUSCI_A1_BASE, &UART_cfg_31250_12MHz);
#endif

    // Enable UART
    MAP_UART_enableModule(EUSCI_A1_BASE);

    // Enable interrupt for RX
    MAP_UART_enableInterrupt(EUSCI_A1_BASE, EUSCI_A_UART_RECEIVE_INTERRUPT);
}

//void uart::midi_uart_2_init() {
//    /* Select GPIO functionality */
//    // P3.2 is UART RX. We don't need TX because we are only receiving MIDI.
//    MAP_GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P3, GPIO_PIN2, GPIO_PRIMARY_MODULE_FUNCTION);
//
////    /* Configure digital oscillator */
////    CS_setDCOCenteredFrequency(CS_DCO_FREQUENCY_12);
//
//    /* Configure UART with 31250 baud rate */
//    MAP_UART_initModule(EUSCI_A2_BASE, &UART_cfg_31250);
//
//    /* Enable UART */
//    MAP_UART_enableModule(EUSCI_A2_BASE);
//}
