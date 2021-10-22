library ieee;
use ieee.std_logic_1164.all;

entity Graphics_Processor is
	port (
		clk, rst : in std_logic;

		vsync, hsync : out std_logic;
		r, g, b : out std_logic_vector(3 downto 0)
	);
end Graphics_Processor;

architecture default of Graphics_Processor is
begin

	U_VGA : entity work.vga_top
		port map(
			clk => clk,
			rst => rst,

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