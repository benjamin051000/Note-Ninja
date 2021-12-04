library ieee;
use ieee.std_logic_1164.all;
use work.vgalib_640x480_60.WIDTH;
use work.vgalib_640x480_60.HEIGHT;


package staff_constants is

    constant CENTER_X : natural := WIDTH / 2;
    constant CENTER_Y : natural := HEIGHT / 2;

    constant LEDGER_WIDTH : natural := WIDTH / 4;
    constant LINE_THICKNESS : natural := 4;

    constant LEDGER_X0 : natural := CENTER_X - LEDGER_WIDTH / 2;
    
    constant STAFF_HEIGHT : natural := HEIGHT/2;
    
    constant LINE_SPACING : natural := STAFF_HEIGHT / 6;
    
    -- Line heights
    constant B_LINE_HEIGHT : natural := CENTER_Y - LINE_THICKNESS / 2;
    constant F_LINE_HEIGHT : natural := B_LINE_HEIGHT - 2 * LINE_SPACING;
    constant D_LINE_HEIGHT : natural := B_LINE_HEIGHT - LINE_SPACING;
    constant G_LINE_HEIGHT : natural := B_LINE_HEIGHT + LINE_SPACING;
    constant E_LINE_HEIGHT : natural := B_LINE_HEIGHT + 2 * LINE_SPACING;


    constant E_HEIGHT : natural := CENTER_Y;

end staff_constants;

-- package note_height_constants is

    

-- end note_height_constants;