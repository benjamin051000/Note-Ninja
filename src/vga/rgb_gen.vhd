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
	
	r, g, b : out std_logic_vector(3 downto 0);

	uart_rx : in std_logic -- uart rx input line
);
end rgb_gen;


architecture bhv of rgb_gen is
	
	-- signal readaddr : std_logic_vector(18 downto 0);
	-- signal q : std_logic_vector(11 downto 0);
	-- signal location : natural;
	-- signal en : std_logic;
	-- signal u_vcnt, u_hcnt, row_offset, col_offset, row, col : unsigned(9 downto 0);
	
	-- signal new_x, new_y : integer range 0 to 480;

	-- signal count : natural range 0 to 100000;

	-- signal update_note : std_logic;


	----------------------------------------------
	signal combined_color : std_logic_vector(11 downto 0);
	
	signal staff_color : std_logic_vector(combined_color'range);
	-- signal note_color: std_logic_vector(combined_color'range); -- 12 bits for R,G,B out

	
	

	-- constant new_y_vals : natural_arr_t(0 to NUMBER_OF_NOTES-1) := (NOTE_LOW_D_HEIGHT, NOTE_LOW_F_HEIGHT, NOTE_A_HEIGHT, NOTE_C_HEIGHT, NOTE_HIGH_E_HEIGHT, NOTE_HIGH_G_HEIGHT);


	


	-- signal new_x_vals, curr_x_vals, new_y_vals : natural_arr_t(0 to NUMBER_OF_NOTES-1);

	signal note_colors : std_logic_vector(combined_color'range);

	-- type visible_arr is array(0 to NUMBER_OF_NOTES-1) of std_logic;
	-- signal visibles : std_logic_vector(NUMBER_OF_NOTES-1 downto 0);
	-- signal notes_pos_reset_arr : std_logic_vector(NUMBER_OF_NOTES-1 downto 0);

	----------------------------------------------------------
	signal reset_uart_buf : std_logic;

	signal advance_notes : std_logic;

	

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
		note_colors
	);


	-- Controller for note movement, based on UART.
	-- process(clk, rst)
	-- begin
	-- 	if(rst = '1')then
	-- 		for i in 0 to NUMBER_OF_NOTES-1 loop
	-- 			new_x_vals(i) <= 640; -- Start them off screen right
	-- 		end loop;

	-- 	elsif(rising_edge(clk)) then
	-- 		update_note <= '0';
			
	-- 		-- Default value for new x values
	-- 		for i in 0 to NUMBER_OF_NOTES-1 loop
	-- 			if(notes_pos_reset_arr(i) = '1') then
	-- 				new_x_vals(i) <= 640; -- Reset this particular note.

	-- 			else
	-- 				new_x_vals(i) <= new_x_vals(i);
	-- 			end if;
	-- 		end loop;

	-- 		if(advance_notes = '1') then
	-- 			-- Move each note to the left.
	-- 			for i in 0 to NUMBER_OF_NOTES-1 loop
	-- 				new_x_vals(i) <= new_x_vals(i) - 1; -- latch inference OK
	-- 			end loop;

	-- 			update_note <= '1';
	-- 		end if;

	-- 	end if;
	-- end process;

	------------------------------------------------------


	-- Logic to create notes and update them.
	-- process(clk, rst)
	-- 	variable note_to_create_idx : natural;
	-- 	variable pitch : natural;
	-- 	variable create_new_note : std_logic;
	-- begin
	-- 	if(rst = '1') then
	-- 		-- Default values
	-- 		advance_notes <= '0';
	-- 		reset_uart_buf <= '0';

	-- 		create_new_note := '0';
	-- 		note_to_create_idx := 0;
	-- 		pitch := 0;
	-- 		notes_pos_reset_arr <= (others => '0');
	-- 		visibles <= (others => '0');
			
	-- 	elsif(rising_edge(clk)) then
	-- 		-- Default values
	-- 		advance_notes <= '0';
	-- 		reset_uart_buf <= '0';

	-- 		create_new_note := '0';
	-- 		note_to_create_idx := 0;
	-- 		pitch := 0;
	-- 		notes_pos_reset_arr <= (others => '0');

	-- 		case rx_byte_reg is
	-- 			when x"41" => -- char "A"
	-- 				advance_notes <= '1';
	-- 				reset_uart_buf <= '1';

	-- 			when x"1D" => -- low D
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_LOW_D_HEIGHT;

	-- 			when x"1E" => -- 1st line "low" E
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_LOW_E_HEIGHT;

	-- 			when x"1F" => -- low F
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_LOW_F_HEIGHT;

	-- 			when x"20" => -- 2nd line "low" G
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_LOW_G_HEIGHT;

	-- 			when x"1A" => -- 2nd space A
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_A_HEIGHT;

	-- 			when x"1B" => -- 3rd line B
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_B_HEIGHT;

	-- 			when x"1C" => -- C
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_C_HEIGHT;

	-- 			when x"2D" => -- 4th line "high" D
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_HIGH_D_HEIGHT;

	-- 			when x"2E" => -- high E
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_HIGH_E_HEIGHT;

	-- 			when x"2F" => -- high F
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_HIGH_F_HEIGHT;

	-- 			when x"30" => -- high G
	-- 				create_new_note := '1';
	-- 				pitch := NOTE_HIGH_G_HEIGHT;
				
	-- 			when others => null;
	-- 		end case;

	-- 		if(create_new_note = '1') then
	-- 			-- 1) Pick note that is currently invisible
	-- 			for i in 0 to NUMBER_OF_NOTES-1 loop
	-- 				if(visibles(i) = '0') then
	-- 					note_to_create_idx := i;
	-- 					exit; -- TODO remove if buggy, it's not completely necessary
	-- 				end if;
	-- 			end loop;

	-- 			-- 2) Use note_to_create_idx index to create a new note.
	-- 			new_y_vals(note_to_create_idx) <= pitch;
	-- 			notes_pos_reset_arr(note_to_create_idx) <= '1'; -- Start it off-screen
	-- 			visibles(note_to_create_idx) <= '1'; -- Note is now visible.
	-- 		end if;
	-- 	end if;
	-- end process;

end bhv;