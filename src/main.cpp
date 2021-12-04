// STL includes
#include <stdio.h> // for sprintf, snprintf
// Library includes
#include <albertOS.h>
// Source file includes
#include "main.h"
#include "uart.h"
#include "midi.h"
#include "threads.h"

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
    uart::threadBackChannelPrint(msg, BackChannel_Info);

    snprintf(msg, 64, "mclk = %d", mclk);
    uart::threadBackChannelPrint(msg, BackChannel_Info);

    snprintf(msg, 64, "smclk = %d", smclk);
    uart::threadBackChannelPrint(msg, BackChannel_Info);

    snprintf(msg, 64, "hsmclk = %d", hsmclk);
    uart::threadBackChannelPrint(msg, BackChannel_Info);

    snprintf(msg, 64, "bclk = %d", bclk);
    uart::threadBackChannelPrint(msg, BackChannel_Info);

    snprintf(msg, 64, "system frequency = %d", system_freq);
    uart::threadBackChannelPrint(msg, BackChannel_Info);
}

void main() {
    albertOS::init();

    uart::back_channel_init();

    // Send clock information over backchannel UART.
    // Doubles as a UART test, and ensures clock is correct speed.
    report_clk_info();

    // Initialize MIDI library
    midi::init();

	// Enable UART RX as an aperiodic event.
#if MIDI_MOCK_NOTES
	albertOS::addThread(send_mock_notes, 1, (char*)"send mock notes");
#else
	albertOS::addAPeriodicEvent(midi_rx_isr, 1, EUSCIA1_IRQn);
#endif

    albertOS::addThread(decode_midi, 1, (char*)"decode midi");

//	albertOS::addThread(midi_read, 1, (char*)"midi read");
	albertOS::addThread(blink_led, 1, (char*)"blink led");

	albertOS::launch();
}
