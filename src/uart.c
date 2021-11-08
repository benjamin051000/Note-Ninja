#include "uart.h"
#include <driverlib.h>

/* Configuration for UART */
const eUSCI_UART_Config UART_cfg_115200 = {
    EUSCI_A_UART_CLOCKSOURCE_SMCLK, // SMCLK Clock Source
    6, // BRDIV
    8, // UCxBRF
    0, // UCxBRS
    EUSCI_A_UART_NO_PARITY,
    EUSCI_A_UART_LSB_FIRST,
    EUSCI_A_UART_ONE_STOP_BIT,
    EUSCI_A_UART_MODE, // UART mode
    EUSCI_A_UART_OVERSAMPLING_BAUDRATE_GENERATION // Oversampling
};


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


void midi_uart_1_init(void) {
    /* Select GPIO functionality */
    // P2.2 is UART RX. We don't need TX because we are only receiving MIDI.
    MAP_GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P2, GPIO_PIN2, GPIO_PRIMARY_MODULE_FUNCTION);

//    /* Configure digital oscillator */
//    CS_setDCOCenteredFrequency(CS_DCO_FREQUENCY_12);

    /* Configure UART with 31250 baud rate */
    MAP_UART_initModule(EUSCI_A1_BASE, &UART_cfg_31250);

    /* Enable UART */
    MAP_UART_enableModule(EUSCI_A1_BASE);
}


void midi_uart_2_init(void) {
    /* Select GPIO functionality */
    // P3.2 is UART RX. We don't need TX because we are only receiving MIDI.
    MAP_GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P3, GPIO_PIN2, GPIO_PRIMARY_MODULE_FUNCTION);

//    /* Configure digital oscillator */
//    CS_setDCOCenteredFrequency(CS_DCO_FREQUENCY_12);

    /* Configure UART with 31250 baud rate */
    MAP_UART_initModule(EUSCI_A2_BASE, &UART_cfg_31250);

    /* Enable UART */
    MAP_UART_enableModule(EUSCI_A2_BASE);
}


/* Initializes back channel UART at 31250 baud (to test settings). */
void back_channel_31250_init(void)
{
    MAP_GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P1, GPIO_PIN2 | GPIO_PIN3, GPIO_PRIMARY_MODULE_FUNCTION);
    MAP_UART_initModule(EUSCI_A0_BASE, &UART_cfg_31250);
    MAP_UART_enableModule(EUSCI_A0_BASE);
}
