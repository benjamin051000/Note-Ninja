# Note Ninja: A musical video game featuring _real instruments!_ 🎸
Senior Design Project created by [Hannah Kirkland](https://github.com/youhoo1234) and [Benjamin Wheeler](https://github.com/benjamin051000).


<!-- TODO add images -->

The goal of Note Ninja is to provide a challenging yet entertaining version of classic video games such as **Guitar Hero** and **Rock Band** to musicians with skill in a particular instrument.

# Platform
* Software target: Texas Instruments MSP432P401R on a custom PCB:

<!-- TODO insert PCB screenshot -->
![Diagram of custom Microprocessor PCB](/images/pcb_mcu.png)

* FPGA target: Terasic DE10-Lite (10M50DAF484C7G)

# Overview
* Microprocessor:
    * Utilizes a custom RTOS ([albertOS](https://github.com/benjamin051000/albertOS)) for thread switching and resource sharing
    * Core game logic
    * MIDI keyboard input and decoding logic
    * Controls graphics
    
* FPGA:
    * Displays graphics on monitor
    * Dynamically renders graphics based on commands recieved from Microprocessor
    
* DSP _(not in repository)_:
    * Guitar pitch detection
    * Score keeping via LCD

# Usage
Clone the project using the `--recuse-submodules` flag:

`git clone --recurse-submodules https://github.com/benjamin051000/Note-Ninja.git`

## Build
<!-- See READMEs in each subdirectory for that particular project's build instructions. -->
* `CCS-Software` is a Texas Instruments [Code Composer Studio](https://www.ti.com/tool/CCSTUDIO) project.
    * Ensure C++ dialects are enabled to C++14.
* `FPGA` is an Intel [Quartus Prime](https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/overview.html) project.
