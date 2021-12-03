#include <stdint.h>
#include <stdio.h>

#include "main.h"

#include "msp.h"
#include "BSP.h"
#include "demo_sysctl.h"
#include <driverlib.h>

#include "uart.h"

#include "MIDI_MSP.h"

#include <albertOS.h>

/**
 * Report clock information
 * via UART.
 *
 * NOTE: BackChannel UART must be enabled before
 * invocation of this function!
 */
void report_clk_info() {
    const uint32_t aclk = CS_getACLK(),
                 mclk = CS_getMCLK(),
                 smclk = CS_getSMCLK(),
                 hsmclk = CS_getHSMCLK(),
                 bclk = CS_getBCLK();

    const uint32_t system_freq = ClockSys_GetSysFreq();

    char msg[64];

    snprintf(msg, 64, "aclk = %d", aclk);
    BackChannelPrint(msg, BackChannel_Info);

    snprintf(msg, 64, "mclk = %d", mclk);
    BackChannelPrint(msg, BackChannel_Info);

    snprintf(msg, 64, "smclk = %d", smclk);
    BackChannelPrint(msg, BackChannel_Info);

    snprintf(msg, 64, "hsmclk = %d", hsmclk);
    BackChannelPrint(msg, BackChannel_Info);

    snprintf(msg, 64, "bclk = %d", bclk);
    BackChannelPrint(msg, BackChannel_Info);

    snprintf(msg, 64, "system frequency = %d", system_freq);
    BackChannelPrint(msg, BackChannel_Info);
}

/////////////////////////////////////////////
// MIDI callback functions
/////////////////////////////////////////////

MIDI_CREATE_PCB_INSTANCE();

struct NoteStatus {
    byte pitch;
    uint32_t systemTime;
};

albertOS::FIFO<NoteStatus, 16> note_on_fifo, note_off_fifo;

Semaphore backchannel_uart_mutex;

void NoteOnHandler(byte channel, byte pitch, byte velocity) {
//    GPIO_setOutputHighOnPin(GPIO_PORT_P1, LED_ONBOARD);
    note_on_fifo.write(NoteStatus {
        pitch,
        systemTime
    });
}

void NoteOffHandler(byte channel, byte pitch, byte velocity) {
//    GPIO_setOutputLowOnPin(GPIO_PORT_P1, LED_ONBOARD);

    note_off_fifo.write(NoteStatus {
        pitch,
        systemTime
    });
}

//void ActiveSensingHandler() {
////    albertOS::waitSemaphore(backchannel_uart_mutex);
////    BackChannelPrint("Active sensing", BackChannel_Info);
////    albertOS::signalSemaphore(backchannel_uart_mutex);
//}

void PitchBendHandler(byte channel, int val) {
    char msg[64];
    snprintf(msg, 64, "pitch bend: channel %d, val %d",
             (int)channel, val);

//    albertOS::waitSemaphore(backchannel_uart_mutex);

//    BackChannelPrint(msg, BackChannel_Info);

//    albertOS::signalSemaphore(backchannel_uart_mutex);
}

void MIDIErrorHandler(int8_t err) {
    char msg[64];
    snprintf(msg, 64, "ERROR: %d", (int)err);

    // This is a PThread! No waiting for semaphores here.
//    albertOS::waitSemaphore(backchannel_uart_mutex);

//    BackChannelPrint(msg, BackChannel_Error);

//    albertOS::signalSemaphore(backchannel_uart_mutex);
}

void midi_init() {
    // Set MIDI callback functions
    MIDI.setHandleNoteOn(NoteOnHandler);
    MIDI.setHandleNoteOff(NoteOffHandler);
//  MIDI.setHandleActiveSensing(ActiveSensingHandler);
//    MIDI.setHandlePitchBend(PitchBendHandler);
//    MIDI.setHandleError(MIDIErrorHandler);


    MIDI.begin(); // Defaults to CH 1
    MIDI.turnThruOff();
}

/**
 * Read once. Good for event threads.
 */
void midi_read_once() {
    MIDI.read();
}
/////////////////////////////////////////////
// albertOS Threads
/////////////////////////////////////////////
void midi_read() {
while(true) {
    MIDI.read();
//    albertOS::sleep(1);
}} // end of thread


void debug_note_on() {
while(true) {
    // Read from the FIFOs and send it to UART.
    const NoteStatus note_on_info = note_on_fifo.read();

    char msg[32];
    snprintf(msg, 32, "ON %d (%d ms)", note_on_info.pitch, note_on_info.systemTime);

    albertOS::waitSemaphore(backchannel_uart_mutex);

    BackChannelPrint(msg, BackChannel_Info);

    albertOS::signalSemaphore(backchannel_uart_mutex);

    albertOS::sleep(100);
}} // end of thread


void debug_note_off() {
while(true) {
    // Read from the FIFOs and send it to UART.
    const NoteStatus note_off_info = note_off_fifo.read();

    char msg[32];
    snprintf(msg, 32, "OFF %d (%d ms)", note_off_info.pitch, note_off_info.systemTime);

    albertOS::waitSemaphore(backchannel_uart_mutex);

    BackChannelPrint(msg, BackChannel_Info);

    albertOS::signalSemaphore(backchannel_uart_mutex);
}} // end of thread


void blink_led() {
    // Set up onboard LED
    GPIO_setAsOutputPin(GPIO_PORT_P1, LED_ONBOARD);
    GPIO_setOutputLowOnPin(GPIO_PORT_P1, LED_ONBOARD);

    while(true) {
        GPIO_toggleOutputOnPin(GPIO_PORT_P1, LED_ONBOARD);
        albertOS::sleep(500);
    }
}


/////////////////////////////////////////////////////////////////
// Event threads
/////////////////////////////////////////////////////////////////
albertOS::FIFO<uint8_t, 64> uartFIFO;

void uart_handler() {
    const auto value = UCA1RXBUF;
    // Ignore ActiveSensing signals.
    if(value != 0xFE) {
        uartFIFO.write(value);
        albertOS::waitSemaphore(backchannel_uart_mutex);

        char msg[32];
        sprintf(msg, "UART: %Xh", value);
        BackChannelPrint(msg, BackChannel_Info);

        albertOS::signalSemaphore(backchannel_uart_mutex);
    }
}


void main() {
#ifdef TARGET_PCB
    UART::back_channel_pcb_init();
#else
    ClockSys_SetMaxFreq();
    BackChannelInit(); // High-frequency setup
#endif
    // Send clock information over backchannel UART.
    // Doubles as a UART test, and ensures clock is correct speed.
    report_clk_info();

    // Initialize MIDI library
    midi_init();

	albertOS::init();

	albertOS::initSemaphore(backchannel_uart_mutex, 1);
//	albertOS::addThread(debug_note_on, 1, (char*)"debug note on");
//	albertOS::addThread(debug_note_off, 1, (char*)"debug note off");

//	albertOS::addThread(midi_read, 1, (char*)"midi read");
	albertOS::addThread(blink_led, 1, (char*)"blink led");

	// Enable UART RX as an aperiodic event.
	albertOS::addAPeriodicEvent(uart_handler, 1, EUSCIA1_IRQn);

//	albertOS::addPeriodicEvent(midi_read_once, 1); // WARNING: Doesn't work if uart read blocks!
//	albertOS::addAPeriodicEvent(midi_read_once, 1, EUSCIA1_IRQn);

	albertOS::launch();
}
