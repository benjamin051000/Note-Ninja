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

	signal count : natural range 0 to 100000;

	signal update_note : std_logic;


	----------------------------------------------
	signal combined_color : std_logic_vector(11 downto 0);
	
	signal staff_color : std_logic_vector(combined_color'range);
	-- signal note_color: std_logic_vector(combined_color'range); -- 12 bits for R,G,B out

	type natural_arr_t is array(0 to 4) of natural;
	
	constant new_y_vals : natural_arr_t := (NOTE_LOW_E_HEIGHT, NOTE_LOW_G_HEIGHT, NOTE_B_HEIGHT, NOTE_HIGH_D_HEIGHT, NOTE_HIGH_F_HEIGHT);

	-- note: range for these is 0-15
	constant color_arr_r : natural_arr_t := (15, 0, 0, 10, 15);
	constant color_arr_g : natural_arr_t := (0, 15, 0, 10, 15);
	constant color_arr_b : natural_arr_t := (0, 0, 15, 10, 15);


	signal new_x_vals : natural_arr_t;

	type note_colors_t is array(0 to 4) of std_logic_vector(combined_color'range);

	signal note_colors : note_colors_t;

	----------------------------------------------------------
	signal received, is_receiving : std_logic;
	signal rx_byte, rx_byte_reg : std_logic_vector(7 downto 0);
	signal reset_uart_buf : std_logic;

	-- function any_or (a : note_colors_t) return std_logic_vector(11 downto 0) is
	-- 	variable temp : std_logic_vector(11 downto 0) := (others => '0');
	-- begin
	-- 	for i in 0 to 4 loop
	-- 		temp := temp or a(i);
	-- 	end loop;
	
	component uart
	generic(
		baud_rate : natural := 9600;
		sys_clk_freq : natural := 100000000 -- 100MHz
	);
	port (
		clk, rst: in std_logic;

		rx : in std_logic; -- incoming serial line
		tx : out std_logic; -- outgoing serial line

		transmit: in std_logic; -- transmit begins transmission
		tx_byte : in std_logic_vector(7 downto 0); -- signal to transmit

		received : out std_logic; -- rx flag
		rx_byte : out std_logic_vector(7 downto 0); -- received byte

		is_receiving, is_transmitting, recv_error : out std_logic; -- status flags
		
		-- Not sure what these do.
		rx_samples, rx_sample_countdown : out std_logic_vector(3 downto 0)
	);
	end component;

	-- Reduce array of vectors into a single vector, using the OR operator.
	function or_reduce(a : note_colors_t) return std_logic_vector is
		variable ret : std_logic_vector(11 downto 0) := (others => '0');
begin
		for i in a'range loop
			ret := ret or a(i);
		end loop;
	
		return ret;
	end function or_reduce;

begin
	combined_color <= staff_color or or_reduce(note_colors);


	r <= combined_color(11 downto 8);
	g <= combined_color(7 downto 4);
	b <= combined_color(3 downto 0);


	------------------------------------------------------------------
	U_STAFF: entity work.staff
	port map(
		clk => clk,
		rst => rst,
		hcount => hcount,
		vcount => vcount,
		color => staff_color
	);

	U_NOTES: for i in 0 to 4 generate
		-- for testing
		U_NOTE: entity work.rect
		generic map(
			w => 50,
			h => NOTE_HEIGHT,
			r => color_arr_r(i),
			g => color_arr_g(i),
			b => color_arr_b(i)
		)
		port map(
			clk,
			rst,
			hcount,
			vcount,
			
			update => update_note,
			new_x => new_x_vals(i),
			new_y => new_y_vals(i),

			color => note_colors(i)
		);
	end generate U_NOTES;

	-- a simple counter to move the note around.
	process(clk, rst)
	begin
		if(rst = '1')then
			count <= 0;

			for i in 0 to 4 loop
				new_x_vals(i) <= 600; -- Start them off screen right
			end loop;

		elsif(rising_edge(clk)) then
			count <= count + 1;

			update_note <= '0';
			
			-- Default value for new x values
			for i in 0 to 4 loop
				new_x_vals(i) <= new_x_vals(i);
			end loop;

			if(count = 100000) then -- 100k

				-- Move each note to the left.
				for i in 0 to 4 loop
					new_x_vals(i) <= new_x_vals(i) - 1; -- latch inference OK
				end loop;

				update_note <= '1';
				count <= 0;
			end if;

		end if;
	end process;

	------------------------------------------------------
	U_UART_IN: uart
	generic map(
		baud_rate => 115200,
		sys_clk_freq => 25000000 -- 25MHz
	)
	port map(
		clk,
		rst,
		uart_rx,
		tx => open,
		transmit => '0',
		tx_byte => (others => '0'),
		received => received, -- will be asserted for one clock cycle.
		rx_byte => rx_byte,
		is_receiving => is_receiving,
		is_transmitting => open,
		recv_error => open,
		rx_samples => open,
		rx_sample_countdown => open
	);
end bhv;