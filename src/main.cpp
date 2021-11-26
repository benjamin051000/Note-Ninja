#include <stdint.h>
#include <stdio.h>

#include "main.h"

#include "msp.h"
#include "BSP.h"
#include "demo_sysctl.h"
#include <driverlib.h>

#include "uart.h"

#include "MIDI_MSP.h"

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
        DelayMs(1000);
    }
}

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


void main() {
    // Run applicable functions of BSP_InitBoard
    /* Disable Watchdog */
    WDT_A_clearTimer();
    WDT_A_holdTimer();

//#ifdef TARGET_PCB
    UART::back_channel_pcb_init();
//#else
////    ClockSys_SetMaxFreq();
////    BackChannelInit();
//#endif

    report_clk_info();



    // Set up onboard LED
    GPIO_setAsOutputPin(GPIO_PORT_P1, LED_ONBOARD);
    GPIO_setOutputLowOnPin(GPIO_PORT_P1, LED_ONBOARD);

//    led_blink_test();

    MIDI_CREATE_PCB_INSTANCE();


    // Set MIDI callback functions
	MIDI.setHandleNoteOn(NoteOnHandler);
	MIDI.setHandleNoteOff(NoteOffHandler);
	MIDI.begin(MIDI_CHANNEL_OMNI);

	while(true) {
	    MIDI.read();
	}
}
