#include <stdint.h>
#include <stdio.h>

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


void NoteOnHandler(byte channel, byte pitch, byte velocity) {
    char msg[255];
    sprintf(msg, "Note On  (Channel: %d, Pitch: %d, Velocity: %d)",
            (int)channel,
            (int)pitch,
            (int)velocity
    );

    BackChannelPrint(msg, BackChannel_Info);
}

void NoteOffHandler(byte channel, byte pitch, byte velocity) {
    char msg[255];
    sprintf(msg, "Note Off (Channel: %d, Pitch: %d, Velocity: %d)",
            (int)channel,
            (int)pitch,
            (int)velocity
    );

    BackChannelPrint(msg, BackChannel_Info);
}


void main()
{
    // Initialize clock source & back channel UART
    BSP_InitBoard();

    // Create MIDI instance
    MSPSerial MSPSerialObj;
    MIDI_CREATE_INSTANCE(MSPSerial, MSPSerialObj, MIDI);

	report_clk_info();

//	midi_uart_1_init();


	MIDI.setHandleNoteOn(NoteOnHandler);
	MIDI.setHandleNoteOff(NoteOffHandler);
	MIDI.begin(MIDI_CHANNEL_OMNI);

//	char msg[128];

//	while(true) {
//	    byte rx = UART_receiveData(EUSCI_A1_BASE);
//
//	    sprintf(msg, "%c", rx);
//	    BackChannelPrint(msg, BackChannel_Info);
//	}


	while(true) {
	    MIDI.read();
	}
}


