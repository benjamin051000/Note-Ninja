/*
 * MIDI_MSP.cpp
 *
 *  Created on: Nov 10, 2021
 *      Author: benja
 */
#include "MIDI_MSP.h"
#include "main.h" // for TARGET_PCB preprocessor symbol
#include <driverlib.h>


namespace {
    /* Configuration for a MIDI-compatible UART at 31250 baud.
     * Uses a 12 MHz SMCLK.
     */
    const eUSCI_UART_Config UART_cfg_31250_12MHz = {
        EUSCI_A_UART_CLOCKSOURCE_SMCLK,
        24, // BRDIV
        0, // UCxBRF
        0, // UCxBRS
        EUSCI_A_UART_NO_PARITY,
        EUSCI_A_UART_LSB_FIRST,
        EUSCI_A_UART_ONE_STOP_BIT,
        EUSCI_A_UART_MODE, // UART mode
        EUSCI_A_UART_OVERSAMPLING_BAUDRATE_GENERATION // Oversampling
    };

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


}


/**
 * Param baudRate is ignored, as it is internally handled and will always be 31250.
 */
void MSPSerial::begin(long baudRate) {

    /* Select GPIO functionality */
    // P2.2 is UART RX. We don't need TX because we are only receiving MIDI.
    MAP_GPIO_setAsPeripheralModuleFunctionInputPin(
            GPIO_PORT_P2,
            GPIO_PIN2,
            GPIO_PRIMARY_MODULE_FUNCTION
    );

    /* Configure UART with 31250 baud rate */
#ifdef TARGET_PCB
    MAP_UART_initModule(EUSCI_A1_BASE, &UART_cfg_31250_3MHz);
#else
    MAP_UART_initModule(EUSCI_A1_BASE, &UART_cfg_31250_12MHz);
#endif

    /* Enable UART */
    MAP_UART_enableModule(EUSCI_A1_BASE);

    // Enable interrupt for Rx
    MAP_UART_enableInterrupt(EUSCI_A1_BASE, EUSCI_A_UART_RECEIVE_INTERRUPT);
}

void MSPSerial::end() {}

void MSPSerial::write(byte value) {
    return; // We will not be writing from this module.
}

byte MSPSerial::read() {
#if 1
    return UART_receiveData(EUSCI_A1_BASE); // TODO this blocks and can't block. Read the register yourself
#else
    if(UCA1IFG & EUSCI_A_IFG_RXIFG) {
        return (byte) UCA1RXBUF; // Reading this reg automatically resets IFG
    }

    return 0;
#endif

}

unsigned MSPSerial::available() {
    const auto result = !UART_queryStatusFlags(EUSCI_A1_BASE, EUSCI_A_UART_BUSY)
            && (UCA1IFG & EUSCI_A_IFG_RXIFG);

    return result;
}


