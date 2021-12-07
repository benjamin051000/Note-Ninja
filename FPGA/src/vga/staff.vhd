library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vgalib_640x480_60.all;
use work.staff_constants.all;

entity staff is
port(
    clk, rst : in std_logic;

    hcount : in natural range 0 to 640;
    vcount : in natural range 0 to 480;

    color : out std_logic_vector(11 downto 0)
);
end staff;

architecture default of staff is
    --Constants------------------------------------------------------
    constant NUM_LINES : natural := 5; -- 5 ledgers
    

    --Type declarations-----------------------------------------------------
    -- Array to hold color values from every note.
    type color_array_t is array(0 to NUM_LINES-1) of std_logic_vector(color'range);
    type param_array_t is array(0 to NUM_LINES-1) of natural;

    --Function Definitions---------------------------------------------------
    -- Reduce array of vectors into single vector using OR operator
	function or_reduce(a : color_array_t) return std_logic_vector is
		variable ret : std_logic_vector(11 downto 0) := (others => '0');
	begin
		for i in a'range loop
			ret := ret or a(i);
		end loop;

		return ret;
	end function or_reduce;


    --Signals--------------------------------------------------------------------
    signal line_colors : color_array_t;
    signal vert_bar_color : std_logic_vector(color'range);
    

    --Line parameters-----------------------------------------------------------
    constant LINE_HEIGHTS : param_array_t := (E_LINE_HEIGHT, G_LINE_HEIGHT, B_LINE_HEIGHT, D_LINE_HEIGHT, F_LINE_HEIGHT);


begin --default--------------------------------------------------------------

    -- Combine colors together for output.
    color <= vert_bar_color or or_reduce(line_colors);

    U_LEDGER_LINES: for i in 0 to NUM_LINES-1 generate
        U_LEDGER_LINE: entity work.rect
        generic map(
            w => LEDGER_WIDTH,
            h => LINE_THICKNESS,

            x0 => LEDGER_X0, -- centerscreen minus offset (center of shape)
            y0 => LINE_HEIGHTS(i),

            r => 15,
            g => 15,
            b => 15
        )
        port map(
            clk,
            rst,
            hcount,
            vcount,
            
            -- Never move x or y.
            update_x => '0',
            reset_x => '0',
    
            set_y => '0',
            new_y => 0,
    
            -- This should always be visible.
            new_visible => '1',
            set_visible => '1',
    
            curr_x => open,
            curr_y => open,
    
            color => line_colors(i)
        );
    end generate U_LEDGER_LINES;

    
    U_VERT_BAR: entity work.rect
    generic map(
        w => LINE_THICKNESS,
        h => HEIGHT/2, -- 1/2 space, so padding should be 1/4 per side

        x0 => CENTER_X,
        y0 => HEIGHT/4, -- 1/8 padding

        r => 15,
        g => 15,
        b => 15
    )
    port map(
        clk,
        rst,
        hcount,
        vcount,
        
        -- Never move x or y.
        update_x => '0',
        reset_x => '0',

        set_y => '0',
        new_y => 0,

        -- This should always be visible.
        new_visible => '1',
        set_visible => '1',

        curr_x => open,
        curr_y => open,

        color => vert_bar_color
    );

end default;