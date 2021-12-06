library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rgb_gen is
port (
	hcount : in natural range 0 to 640;
    vcount : in natural range 0 to 480;
	
	video_on : in std_logic;
	clk, rst : in std_logic;
	
	r, g, b : out std_logic_vector(3 downto 0);

	uart_rx : in std_logic; -- uart rx input line
	uart_tx : out std_logic -- uart outgoing serial line
);
end rgb_gen;


architecture bhv of rgb_gen is

	signal combined_color : std_logic_vector(11 downto 0);
	
	signal staff_color : std_logic_vector(combined_color'range);
	
	signal note_colors : std_logic_vector(combined_color'range);

begin -- bhv

	combined_color <= staff_color or note_colors;

	r <= combined_color(11 downto 8);
	g <= combined_color(7 downto 4);
	b <= combined_color(3 downto 0);

	U_STAFF: entity work.staff
	port map(
		clk => clk,
		rst => rst,
		hcount => hcount,
		vcount => vcount,
		color => staff_color
	);

	U_NOTEGEN : entity work.notegen
	port map(
		clk,
		rst,
		
		hcount,
		vcount,

		uart_rx,
		uart_tx,

		note_colors
	);

end bhv;