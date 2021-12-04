library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vgalib_640x480_60.all;

entity staff is
port(
    clk, rst : in std_logic;

    hcount : in natural range 0 to 640;
    vcount : in natural range 0 to 480;

    color : out std_logic_vector(11 downto 0)
);
end staff;

architecture default of staff is
    signal vert_bar_color, g_ledger_color, d_ledger_color, b_ledger_color, f_ledger_color, e_ledger_color : std_logic_vector(color'range);

    constant CENTER_X : natural := WIDTH / 2;
    constant CENTER_Y : natural := HEIGHT / 2;

    constant LEDGER_WIDTH : natural := WIDTH / 4;
    constant LINE_THICKNESS : natural := 4;

    constant LEDGER_X0 : natural := CENTER_X - LEDGER_WIDTH / 2;
    
    constant STAFF_HEIGHT : natural := HEIGHT/2;
    
    constant LINE_SPACING : natural := STAFF_HEIGHT / 6;
    
    -- Line heights
    constant CENTER_LINE_HEIGHT : natural := CENTER_Y - LINE_THICKNESS / 2;
    constant TOP_LINE_HEIGHT : natural := CENTER_LINE_HEIGHT - 2 * LINE_SPACING;
    constant D_LINE_HEIGHT : natural := CENTER_LINE_HEIGHT - LINE_SPACING;
    constant G_LINE_HEIGHT : natural := CENTER_LINE_HEIGHT + LINE_SPACING;
    constant BOTTOM_LINE_HEIGHT : natural := CENTER_LINE_HEIGHT + 2 * LINE_SPACING;

begin

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
        update => '0',

        new_x => 0, -- unused
        new_y => 0, -- unused
        
        color => vert_bar_color
    );

    -- U_LEDGER_LINES : for line_height in BOTTOM_LINE to TOP_LINE generate


    -- Draw ledger lines
    U_F_LEDGER: entity work.rect
    generic map(
        w => LEDGER_WIDTH,
        h => LINE_THICKNESS,

        x0 => LEDGER_X0, -- centerscreen minus offset: center of shape
        y0 => TOP_LINE_HEIGHT,

        r => 15,
        g => 15,
        b => 15
    )
    port map(
        clk,
        rst,
        hcount,
        vcount,
        update => '0',

        new_x => 0, -- unused
        new_y => 0, -- unused
        
        color => f_ledger_color
    );

    U_D_LEDGER: entity work.rect
    generic map(
        w => LEDGER_WIDTH,
        h => LINE_THICKNESS,

        x0 => LEDGER_X0, -- centerscreen minus offset: center of shape
        y0 => D_LINE_HEIGHT,

        r => 15,
        g => 15,
        b => 15
    )
    port map(
        clk,
        rst,
        hcount,
        vcount,
        update => '0',

        new_x => 0, -- unused
        new_y => 0, -- unused
        
        color => d_ledger_color
    );

    U_B_LEDGER: entity work.rect
    generic map(
        w => LEDGER_WIDTH,
        h => LINE_THICKNESS,

        x0 => LEDGER_X0,
        y0 => CENTER_LINE_HEIGHT,

        r => 15,
        g => 15,
        b => 15
    )
    port map(
        clk,
        rst,
        hcount,
        vcount,
        update => '0',

        new_x => 0, -- unused
        new_y => 0, -- unused
        
        color => b_ledger_color
    );

    U_G_LEDGER: entity work.rect
    generic map(
        w => LEDGER_WIDTH,
        h => LINE_THICKNESS,

        x0 => LEDGER_X0, -- centerscreen minus offset: center of shape
        y0 => G_LINE_HEIGHT,

        r => 15,
        g => 15,
        b => 15
    )
    port map(
        clk,
        rst,
        hcount,
        vcount,
        update => '0',

        new_x => 0, -- unused
        new_y => 0, -- unused
        
        color => g_ledger_color
    );   

    U_E_LEDGER: entity work.rect
    generic map(
        w => LEDGER_WIDTH,
        h => LINE_THICKNESS,

        x0 => LEDGER_X0, -- centerscreen minus offset: center of shape
        y0 => BOTTOM_LINE_HEIGHT,

        r => 15,
        g => 15,
        b => 15
    )
    port map(
        clk,
        rst,
        hcount,
        vcount,
        update => '0',

        new_x => 0, -- unused
        new_y => 0, -- unused
        
        color => e_ledger_color
    );   




    color <= vert_bar_color or f_ledger_color or d_ledger_color or b_ledger_color or g_ledger_color or e_ledger_color;

end default;