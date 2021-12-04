library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vgalib_640x480_60.all;
use work.staff_constants.all;

entity rgb_gen is
port (
	-- vcount, hcount : in std_logic_vector(9 downto 0);
	hcount : in natural range 0 to 640;
    vcount : in natural range 0 to 480;
	-- video_on and vsync controlled by sync gen
	-- video_on, vsync : in std_logic;
	video_on : in std_logic;
	clk, rst : in std_logic;

	-- cpu_says_swap_buf : in std_logic;
	-- swap_complete : out std_logic;
	-- wraddr : in std_logic_vector(18 downto 0);
	-- data : in std_logic_vector(11 downto 0);
	-- back_buf_wren : in std_logic;
	
	r, g, b : out std_logic_vector(3 downto 0)
);
end rgb_gen;


architecture bhv of rgb_gen is
	
	-- signal readaddr : std_logic_vector(18 downto 0);
	-- signal q : std_logic_vector(11 downto 0);
	-- signal location : natural;
	-- signal en : std_logic;
	-- signal u_vcnt, u_hcnt, row_offset, col_offset, row, col : unsigned(9 downto 0);
	
	signal new_x, new_y : integer range 0 to 480;

	signal count : natural range 0 to 50000;

	signal update_note : std_logic;


	----------------------------------------------
	signal combined_color : std_logic_vector(11 downto 0);
	
	signal staff_color : std_logic_vector(combined_color'range);
	signal note_color: std_logic_vector(combined_color'range); -- 12 bits for R,G,B out

	type note_height_arr is array(0 to 11) of natural;
	-- constant note_heights : note_height_arr := ();

begin

	-- r <= "1111" when (video_on = '1' and vcount - hcount >= 75) else "0000";
	-- g <= "1111" when (video_on = '1' and vcount - hcount < 100) else "0000";
	-- b <= "1111" when video_on = '1' and vcount < hcount else "0000";
	r <= combined_color(11 downto 8);
	g <= combined_color(7 downto 4);
	b <= combined_color(3 downto 0);

	combined_color <= staff_color or note_color;
	
	U_STAFF: entity work.staff
	port map(
		clk => clk,
		rst => rst,
		hcount => hcount,
		vcount => vcount,
		color => staff_color
	);

	-- for testing
	U_NOTE: entity work.rect
	generic map(
		w => 50,
		h => 25
	)
	port map(
		vcount => vcount,
		hcount => hcount,
		
		clk => clk,
		rst => rst,
		
		update => update_note,
		new_x => new_x,
		new_y => new_y,

		color => note_color
	);

	-- a simple counter to move the note around.
	process(clk, rst)
	begin
		if(rst = '1')then
			count <= 0;
			new_x <= 0;
			new_y <= 0;
		elsif(rising_edge(clk)) then
			count <= count + 1;

			update_note <= '0';

			if(count = 50000) then
				new_x <= new_x + 1;
				new_y <= new_y + 1;
				update_note <= '1';
			end if;
		end if;
	end process;



end bhv;