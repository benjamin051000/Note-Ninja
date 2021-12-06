#include "uart.h"
#include <driverlib.h>
#include <albertOS.h>
#include "main.h"

// Local namespace
namespace {
/* Configuration for UART for a 3MHz SMCLK. */
const eUSCI_UART_Config UART_cfg_115200_3MHz = {
    EUSCI_A_UART_CLOCKSOURCE_SMCLK, // SMCLK Clock Source
    26, // BRDIV
    0, // UCxBRF
    0, // UCxBRS
    EUSCI_A_UART_NO_PARITY,
    EUSCI_A_UART_LSB_FIRST,
    EUSCI_A_UART_ONE_STOP_BIT,
    EUSCI_A_UART_MODE, // UART mode
    // Oversampling disabled
};


const eUSCI_UART_Config UART_cfg_9600_3MHz = {
    EUSCI_A_UART_CLOCKSOURCE_SMCLK, // SMCLK Clock Source
    19, // BRDIV
    8, // UCxBRF
    0, // UCxBRS
    EUSCI_A_UART_NO_PARITY,
    EUSCI_A_UART_LSB_FIRST,
    EUSCI_A_UART_ONE_STOP_BIT,
    EUSCI_A_UART_MODE, // UART mode
    EUSCI_A_UART_OVERSAMPLING_BAUDRATE_GENERATION // Oversampling
};


/* Configuration for a MIDI-compatible UART at 31250 baud. */
//const eUSCI_UART_Config UART_cfg_31250_12MHz = {
//    EUSCI_A_UART_CLOCKSOURCE_SMCLK,
//    24, // BRDIV
//    0, // UCxBRF
//    0, // UCxBRS
//    EUSCI_A_UART_NO_PARITY,
//    EUSCI_A_UART_LSB_FIRST,
//    EUSCI_A_UART_ONE_STOP_BIT,
//    EUSCI_A_UART_MODE, // UART mode
//    EUSCI_A_UART_OVERSAMPLING_BAUDRATE_GENERATION // Oversampling
//};

// Semaphore for threadBackChannelPrint.
Semaphore backchannel_uart_mutex;

} // end of anonymous namespace


void uart::init_port1() {
#if TARGET_PCB
    MAP_GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P1, GPIO_PIN2 | GPIO_PIN3, GPIO_PRIMARY_MODULE_FUNCTION); // TODO shouldn't TX be Output func? It still works...
//    MAP_UART_initModule(EUSCI_A0_BASE, &UART_cfg_115200_3MHz);
    MAP_UART_initModule(EUSCI_A0_BASE, &UART_cfg_9600_3MHz);
    MAP_UART_enableModule(EUSCI_A0_BASE);

#else
    ClockSys_SetMaxFreq();
    BackChannelInit(); // High-frequency setup
#endif

    // Initialize backchannel uart mutex
    albertOS::initSemaphore(backchannel_uart_mutex, 1);
}

void uart::init_guitar() {
    // Initialize UART input from guitar.
    MAP_GPIO_setAsPeripheralModuleFunctionInputPin(GPIO_PORT_P3, GPIO_PIN2, GPIO_PRIMARY_MODULE_FUNCTION); // TODO shouldn't TX be Output func? It still works...
    MAP_UART_initModule(EUSCI_A2_BASE, &UART_cfg_9600_3MHz);
    MAP_UART_enableModule(EUSCI_A2_BASE);
}


/**
 * Uses a mutex to print to the backchannel UART in a thread-safe way.
 */
void uart::threadBackChannelPrint(const char* str, BackChannelTextStyle_t style) {
    albertOS::waitSemaphore(backchannel_uart_mutex);
    BackChannelPrint(str, style);
    albertOS::signalSemaphore(backchannel_uart_mutex);
}

/**
 * Send a plain string with no logging level syntax.
 */
void uart::thread_port1_send_str(const char* str) {
    albertOS::waitSemaphore(backchannel_uart_mutex);
    // Loop over each char until null.
    while(*str) {
        MAP_UART_transmitData(EUSCI_A0_BASE, *str++);
    }
    albertOS::signalSemaphore(backchannel_uart_mutex);
}

void uart::send_fpga_command(FPGACommand cmd) {
    albertOS::waitSemaphore(backchannel_uart_mutex);

    MAP_UART_transmitData(EUSCI_A0_BASE, (uint8_t)cmd);

    albertOS::signalSemaphore(backchannel_uart_mutex);
}


