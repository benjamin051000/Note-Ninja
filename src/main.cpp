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

MIDI_CREATE_PCB_INSTANCE();

/**
 * Report clock information
 * via UART.
 *
 * NOTE: BackChannel UART must be enabled before
 * invocation of this function!
 */
void report_clk_info() {
    uint32_t aclk = CS_getACLK(),
                 mclk = CS_getMCLK(),
                 smclk = CS_getSMCLK(),
                 hsmclk = CS_getHSMCLK(),
                 bclk = CS_getBCLK();

    uint32_t system_freq = ClockSys_GetSysFreq();

    char msg[255];

    sprintf(msg, "aclk = %d", aclk);
    BackChannelPrint(msg, BackChannel_Info);

    sprintf(msg, "mclk = %d", mclk);
    BackChannelPrint(msg, BackChannel_Info);

    sprintf(msg, "smclk = %d", smclk);
    BackChannelPrint(msg, BackChannel_Info);

    sprintf(msg, "hsmclk = %d", hsmclk);
    BackChannelPrint(msg, BackChannel_Info);

    sprintf(msg, "bclk = %d", bclk);
    BackChannelPrint(msg, BackChannel_Info);

    sprintf(msg, "system frequency = %d", system_freq);
    BackChannelPrint(msg, BackChannel_Info);
}

void led_blink_test() {
    while(true) {
        GPIO_toggleOutputOnPin(GPIO_PORT_P1, LED_ONBOARD);
        albertOS::sleep(1000);
    }
}

/////////////////////////////////////////////
// MIDI callback functions
/////////////////////////////////////////////
void NoteOnHandler(byte channel, byte pitch, byte velocity) {
    char msg[255];
    snprintf(msg, 255, "Note On  (Channel: %d, Pitch: %d, Velocity: %d)",
            (int)channel,
            (int)pitch,
            (int)velocity
    );

    BackChannelPrint(msg, BackChannel_Info);

    GPIO_setOutputHighOnPin(GPIO_PORT_P1, LED_ONBOARD);
}

void NoteOffHandler(byte channel, byte pitch, byte velocity) {
    char msg[255];
    snprintf(msg, 255, "Note Off (Channel: %d, Pitch: %d, Velocity: %d)",
            (int)channel,
            (int)pitch,
            (int)velocity
    );

    BackChannelPrint(msg, BackChannel_Info);

    GPIO_setOutputLowOnPin(GPIO_PORT_P1, LED_ONBOARD);
}

void ActiveSensingHandler() {
    BackChannelPrint("Active sensing", BackChannel_Info);
}

void PitchBendHandler(byte channel, int val) {
    char msg[255];
    snprintf(msg, 255, "pitch bend: channel %d, val=%d",
             (int)channel, val);
    BackChannelPrint(msg, BackChannel_Info);
}

void MIDIErrorHandler(int8_t err) {
    char msg[64];
    snprintf(msg, 255, "ERROR: %d", (int)err);
    BackChannelPrint(msg, BackChannel_Error);
}


/////////////////////////////////////////////
// albertOS Threads
/////////////////////////////////////////////
void idle() {
    while(true);
}

void midi_read() {
while(true) {
    MIDI.read();
//    DelayMs(2); // do we get here?
//    albertOS::sleep(2); // allow other threads to run
}
}

void blink_rgb() {
while(true) {
    GPIO_toggleOutputOnPin(GPIO_PORT_P2, GPIO_PIN1);
    albertOS::sleep(1000);
}
}

void main() {
    // Run applicable functions of BSP_InitBoard
    /* Disable Watchdog */
    WDT_A_clearTimer();
    WDT_A_holdTimer();

    UART::back_channel_pcb_init();

    report_clk_info();



    // Set up onboard LED
    GPIO_setAsOutputPin(GPIO_PORT_P1, LED_ONBOARD);
    GPIO_setOutputLowOnPin(GPIO_PORT_P1, LED_ONBOARD);

    // Set up RGB LED
    GPIO_setAsOutputPin(GPIO_PORT_P2, GPIO_PIN0 | GPIO_PIN1);
    GPIO_setOutputLowOnPin(GPIO_PORT_P2, GPIO_PIN0 | GPIO_PIN1);

//    led_blink_test();


    // Set MIDI callback functions
	MIDI.setHandleNoteOn(NoteOnHandler);
	MIDI.setHandleNoteOff(NoteOffHandler);
//	MIDI.setHandleActiveSensing(ActiveSensingHandler);
	MIDI.setHandlePitchBend(PitchBendHandler);
	MIDI.setHandleError(MIDIErrorHandler);


	MIDI.begin(); // Defaults to CH 1
	MIDI.turnThruOff();

//	while(true) MIDI.read();


	albertOS::init();

	albertOS::addThread(idle, 255, (char*)"Idle");


//	albertOS::addPeriodicEvent([](){
//	    MIDI.read();
//	}, 2);

	albertOS::addThread(midi_read, 1, (char*)"midi read");

	albertOS::launch();
}
