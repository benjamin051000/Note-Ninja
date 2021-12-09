library ieee;
use ieee.std_logic_1164.all;

entity vga_top is
	port (
		clk, rst : in std_logic;

		-- Signals for receiving VRAM data from CPU
		-- Instruction from CPU that the buffer is done and ready to be swapped.
		-- cpu_says_swap_buf : in std_logic; 
		-- Flag for CPU once buffers have been swapped.
		-- swap_complete : out std_logic; 
		
		-- Address and data lines for incoming data from CPU to the back buffer.
		-- wraddr : in std_logic_vector(18 downto 0);
		-- data : in std_logic_vector(11 downto 0);

		-- back_buf_wren : in std_logic;
		
		-- Output signals to the display.
		vga_hsync, vga_vsync : out std_logic;
		r, g, b : out std_logic_vector(3 downto 0);

		uart_rx : in std_logic;
		uart_tx : out std_logic -- uart outgoing serial line

	);
end vga_top;


architecture STR of vga_top is

	-- For active-low signals
	signal button_n : std_logic_vector(1 downto 0);

	-- VGA signals
	-- signal hcount, vcount : std_logic_vector(9 downto 0);
	signal hcount : natural range 0 to 640;
    signal vcount : natural range 0 to 480;

	signal video_on : std_logic;
	signal vsync_signal : std_logic;

begin -- STR

	vga_vsync <= vsync_signal;

	-- VGA Sync Gen
	U_VGA_SYNC : entity work.vga_sync_gen
		port map(
			clk => clk,
			rst => rst,
			hcount => hcount,
			vcount => vcount,
			hsync => vga_hsync,
			vsync => vsync_signal,
			video_on => video_on
		);

	-- VGA video output generator
	U_RGB_GEN : entity work.rgb_gen
		port map(
			vcount => vcount,
			hcount => hcount,
			clk => clk,
			rst => rst,

			-- cpu_says_swap_buf => cpu_says_swap_buf,
			-- swap_complete => swap_complete,
			-- wraddr => wraddr,
			-- data => data,
			-- back_buf_wren => back_buf_wren,
			-- vsync => vsync_signal,


			video_on => video_on,
			r => r,
			g => g,
			b => b,
			uart_rx => uart_rx,
			uart_tx => uart_tx
		);

end STR;
