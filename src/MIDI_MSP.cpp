/*
 * MIDI_MSP.cpp
 *
 *  Created on: Nov 10, 2021
 *      Author: benja
 */
#include "MIDI_MSP.h"
#include <driverlib.h>


namespace {
    /* Configuration for a MIDI-compatible UART at 31250 baud. */
    const eUSCI_UART_Config UART_cfg_31250 = {
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


}


/**
 * Param baudRate is ignored, as it is internaly handled and will always be 31250.
 */
void MSPSerial::begin(long baudRate) {
    /* Select GPIO functionality */
    // P2.2 is UART RX. We don't need TX because we are only receiving MIDI.
    MAP_GPIO_setAsPeripheralModuleFunctionInputPin(
            GPIO_PORT_P2,
            GPIO_PIN2,
            GPIO_PRIMARY_MODULE_FUNCTION
    );

    /* Configure digital oscillator */
//    CS_setDCOCenteredFrequency(CS_DCO_FREQUENCY_12);

    /* Configure UART with 31250 baud rate */
    MAP_UART_initModule(EUSCI_A1_BASE, &UART_cfg_31250);

    /* Enable UART */
    MAP_UART_enableModule(EUSCI_A1_BASE);
}

void MSPSerial::end() {}

void MSPSerial::write(byte value) {
    return; // We will not be writing via this.
}

byte MSPSerial::read() {
    return UART_receiveData(EUSCI_A1_BASE);
}

unsigned MSPSerial::available() {
//    return UART_queryStatusFlags(EUSCI_A1_BASE, EUSCI_A_UART_BUSY);
    return true;
}


