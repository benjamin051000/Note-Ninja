library ieee;
use ieee.std_logic_1164.all;

entity Graphics_Processor is
	port (
		clk50MHz, rst_l : in std_logic;

		vsync, hsync : out std_logic;
		r, g, b : out std_logic_vector(3 downto 0);

		uart_rx : in std_logic; -- incoming UART line
		uart_tx : out std_logic -- uart outgoing serial line
		
	);
end Graphics_Processor;

architecture default of Graphics_Processor is

signal clk : std_logic;

-- signal clk100MHz, clk108MHz, clk150MHz, clk200MHz : std_logic;

signal rst : std_logic;


begin

	rst <= not rst_l;

	U_CLK_DIV : entity work.clk_div
	generic map(
		clk_in_freq => 50,
        clk_out_freq => 25 -- 25 MHz out
	)		
   port map (
        clk_in  => clk50MHz,
        clk_out => clk,
		rst => rst
	);

	U_VGA : entity work.vga_top
		port map(
			clk => clk,
			rst => rst,

			vga_hsync => hsync,
			vga_vsync => vsync,
			r => r,
			g => g,
			b => b,

			uart_rx => uart_rx,
			uart_tx => uart_tx

		);

end default;
