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
    

    -- Point at which the center of each line is.
    constant B_LINE_CENTER : natural := CENTER_Y;
    constant F_LINE_CENTER : natural := B_LINE_CENTER - 2 * LINE_SPACING;
    constant D_LINE_CENTER : natural := B_LINE_CENTER - LINE_SPACING;
    constant G_LINE_CENTER : natural := B_LINE_CENTER + LINE_SPACING;
    constant E_LINE_CENTER : natural := B_LINE_CENTER + 2 * LINE_SPACING;


    -- Line heights (accounts for line thickness)
    constant F_LINE_HEIGHT : natural := F_LINE_CENTER - LINE_THICKNESS / 2;
    constant D_LINE_HEIGHT : natural := D_LINE_CENTER - LINE_THICKNESS / 2;
    constant B_LINE_HEIGHT : natural := B_LINE_CENTER - LINE_THICKNESS / 2;
    constant G_LINE_HEIGHT : natural := G_LINE_CENTER - LINE_THICKNESS / 2;
    constant E_LINE_HEIGHT : natural := E_LINE_CENTER - LINE_THICKNESS / 2;


    -- note heights, which are calculated from the ledger line centers.
    constant NOTE_HEIGHT : natural := 30; -- notes should be 30 pixels tall
    
    constant NOTE_HIGH_F_HEIGHT : natural := F_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_HIGH_D_HEIGHT : natural := D_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_B_HEIGHT      : natural := B_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_LOW_G_HEIGHT  : natural := G_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_LOW_E_HEIGHT  : natural := E_LINE_CENTER - NOTE_HEIGHT / 2;


end staff_constants;

-- package note_height_constants is

    

-- end note_height_constants;