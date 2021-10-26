library ieee;
use ieee.std_logic_1164.all;

entity Graphics_Processor is
	port (
		clk50MHz, rst : in std_logic;

		vsync, hsync : out std_logic;
		r, g, b : out std_logic_vector(3 downto 0)
	);
end Graphics_Processor;

architecture default of Graphics_Processor is

signal clk25MHz : std_logic;

begin

	U_CLK_DIV : entity work.clk_div
	generic map(
				clk_in_freq => 50,
            clk_out_freq => 25--25000000
	)
				
   port map (
        clk_in  => clk50MHz,
        clk_out => clk25MHz,
		  rst => not rst
	);

	U_VGA : entity work.vga_top
		port map(
			clk => clk25MHz,
			rst => not rst,

			vga_hsync => hsync,
			vga_vsync => vsync,
			r => r,
			g => g,
			b => b,

			-- Unused (will likely be removed for this project)
			cpu_says_swap_buf => '0',
			wraddr => (others => '0'),
			data => (others => '0'),
			back_buf_wren => '0'
		);

end default;