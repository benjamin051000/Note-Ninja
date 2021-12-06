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
    
    ---------------------------------------------------------------------------
    -- Point at which the center of each line is.
    -- Intermediate values, see NOTE_XXX_HEIGHT below to align the notes.
    constant B_LINE_CENTER : natural := CENTER_Y;
    constant F_LINE_CENTER : natural := B_LINE_CENTER - 2 * LINE_SPACING;
    constant D_LINE_CENTER : natural := B_LINE_CENTER - LINE_SPACING;
    constant G_LINE_CENTER : natural := B_LINE_CENTER + LINE_SPACING;
    constant E_LINE_CENTER : natural := B_LINE_CENTER + 2 * LINE_SPACING;

    -- spaces (no visible lines here)
    constant LOW_D_LINE_CENTER : natural := B_LINE_CENTER + 5 * LINE_SPACING / 2; -- 5/2 = 2.5 line spaces
    constant LOW_F_LINE_CENTER : natural := B_LINE_CENTER + 3 * LINE_SPACING / 2; -- 3/2 = 1.5
    constant A_LINE_CENTER : natural := B_LINE_CENTER + LINE_SPACING / 2; -- 1/2 line spaces
    constant C_LINE_CENTER : natural := B_LINE_CENTER - LINE_SPACING / 2;
    constant HIGH_E_LINE_CENTER : natural := B_LINE_CENTER - 3 * LINE_SPACING / 2;
    constant HIGH_G_LINE_CENTER : natural := B_LINE_CENTER - 5 * LINE_SPACING / 2;

    ---------------------------------------------------------------------------
    -- Line heights (accounts for line thickness)
    constant F_LINE_HEIGHT : natural := F_LINE_CENTER - LINE_THICKNESS / 2;
    constant D_LINE_HEIGHT : natural := D_LINE_CENTER - LINE_THICKNESS / 2;
    constant B_LINE_HEIGHT : natural := B_LINE_CENTER - LINE_THICKNESS / 2;
    constant G_LINE_HEIGHT : natural := G_LINE_CENTER - LINE_THICKNESS / 2;
    constant E_LINE_HEIGHT : natural := E_LINE_CENTER - LINE_THICKNESS / 2;

    -- spaces
    -- not needed for spaces, since we won't display a line on these anyway.
    -- constant LOW_F_LINE_HEIGHT : natural := LOW_F_LINE_CENTER - LINE_THICKNESS / 2;

    ---------------------------------------------------------------------------
    -- note heights, which are calculated from the ledger line centers.
    constant NOTE_HEIGHT : natural := 30; -- notes should be 30 pixels tall
    
    constant NOTE_HIGH_F_HEIGHT : natural := F_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_HIGH_D_HEIGHT : natural := D_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_B_HEIGHT      : natural := B_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_LOW_G_HEIGHT  : natural := G_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_LOW_E_HEIGHT  : natural := E_LINE_CENTER - NOTE_HEIGHT / 2;
    
    -- spaces
    constant NOTE_LOW_D_HEIGHT : natural := LOW_D_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_LOW_F_HEIGHT : natural := LOW_F_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_A_HEIGHT : natural := A_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_C_HEIGHT : natural := C_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_HIGH_E_HEIGHT : natural := HIGH_E_LINE_CENTER - NOTE_HEIGHT / 2;
    constant NOTE_HIGH_G_HEIGHT : natural := HIGH_G_LINE_CENTER - NOTE_HEIGHT / 2;

end staff_constants;


------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package uart_commands is
    subtype byte_t is std_logic_vector(7 downto 0);

    constant ADVANCE_NOTES : byte_t := x"41";
    
    constant CREATE_LOW_D : byte_t := x"42";
    constant CREATE_LOW_E : byte_t := x"43";
    constant CREATE_LOW_F : byte_t := x"44";
    constant CREATE_LOW_G : byte_t := x"45";

    constant CREATE_A : byte_t := x"46";
    constant CREATE_B : byte_t := x"47";
    constant CREATE_C : byte_t := x"48";
    
    constant CREATE_HIGH_D : byte_t := x"49";
    constant CREATE_HIGH_E : byte_t := x"4A";
    constant CREATE_HIGH_F : byte_t := x"4B";
    constant CREATE_HIGH_G : byte_t := x"4C";

end uart_commands;