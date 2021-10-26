-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------
-- 640x480 @ 60Hz
-- Requires 25.175 MHz clock
-- Timings adjusted very slightly to accomodate for 25.0 MHz clock
package vgalib_640x480_60 is

  -- COUNTER VALUES FOR GENERATING H_SYNC AND V_SYNC
  
  constant H_DISPLAY_END : integer := 639; -- start of fp
  constant HSYNC_BEGIN   : integer := 659;
  constant HSYNC_END     : integer := 755;
  constant H_MAX         : integer := 799; -- reset to 0

  constant H_VERT_INC    : integer := 699;
  
  constant V_DISPLAY_END : integer := 479; -- start of fp
  constant VSYNC_BEGIN   : integer := 493;
  constant VSYNC_END     : integer := 494;
  constant V_MAX         : integer := 524; -- reset to 0

  -----------------------------------------------------------------------------
  -- CONSTANTS DEFINING PIXEL BOUNDARIES OF THE IMAGE FOR EACH IMAGE LOCATION
  
  constant TOP_LEFT_X_START : integer := 0;
  constant TOP_LEFT_X_END   : integer := 127;
  constant TOP_LEFT_Y_START : integer := 0;
  constant TOP_LEFT_Y_END   : integer := 127;

  constant TOP_RIGHT_X_START : integer := 511;
  constant TOP_RIGHT_X_END   : integer := 639;
  constant TOP_RIGHT_Y_START : integer := 0;
  constant TOP_RIGHT_Y_END   : integer := 127;

  constant BOTTOM_RIGHT_X_START : integer := 511;
  constant BOTTOM_RIGHT_X_END   : integer := 639;
  constant BOTTOM_RIGHT_Y_START : integer := 351;
  constant BOTTOM_RIGHT_Y_END   : integer := 479;

  constant BOTTOM_LEFT_X_START : integer := 0;
  constant BOTTOM_LEFT_X_END   : integer := 127;
  constant BOTTOM_LEFT_Y_START : integer := 351;
  constant BOTTOM_LEFT_Y_END   : integer := 479;

  constant CENTERED_X_START : integer := 255;
  constant CENTERED_X_END   : integer := 383;
  constant CENTERED_Y_START : integer := 175;
  constant CENTERED_Y_END   : integer := 303;
  
end vgalib_640x480_60;


----------------------------------------------------------
-- 800x600 @72Hz
-- Requires 50.0 MHz clock
-- That's convenient!
package vgalib_800x600_72 is


  -- COUNTER VALUES FOR GENERATING H_SYNC AND V_SYNC
  
  constant H_DISPLAY_END : integer := 800-1; -- start of fp
  constant HSYNC_BEGIN   : integer := H_DISPLAY_END + 56;
  constant HSYNC_END     : integer := HSYNC_BEGIN + 120;
  constant H_MAX         : integer := HSYNC_END + 64; -- reset to 0

  constant H_VERT_INC    : integer := HSYNC_BEGIN + 60; -- halfway through hsync pulse
  
  constant V_DISPLAY_END : integer := 600-1; -- start of fp
  constant VSYNC_BEGIN   : integer := V_DISPLAY_END + 37;
  constant VSYNC_END     : integer := VSYNC_BEGIN + 6;
  constant V_MAX         : integer := VSYNC_END + 23; -- reset to 0

  -----------------------------------------------------------------------------
  -- CONSTANTS DEFINING PIXEL BOUNDARIES OF THE IMAGE FOR EACH IMAGE LOCATION
  
  constant TOP_LEFT_X_START : integer := 0;
  constant TOP_LEFT_X_END   : integer := 127;
  constant TOP_LEFT_Y_START : integer := 0;
  constant TOP_LEFT_Y_END   : integer := 127;

  constant TOP_RIGHT_X_START : integer := 511;
  constant TOP_RIGHT_X_END   : integer := 639;
  constant TOP_RIGHT_Y_START : integer := 0;
  constant TOP_RIGHT_Y_END   : integer := 127;

  constant BOTTOM_RIGHT_X_START : integer := 511;
  constant BOTTOM_RIGHT_X_END   : integer := 639;
  constant BOTTOM_RIGHT_Y_START : integer := 351;
  constant BOTTOM_RIGHT_Y_END   : integer := 479;

  constant BOTTOM_LEFT_X_START : integer := 0;
  constant BOTTOM_LEFT_X_END   : integer := 127;
  constant BOTTOM_LEFT_Y_START : integer := 351;
  constant BOTTOM_LEFT_Y_END   : integer := 479;

  constant CENTERED_X_START : integer := 255;
  constant CENTERED_X_END   : integer := 383;
  constant CENTERED_Y_START : integer := 175;
  constant CENTERED_Y_END   : integer := 303;
  

end vgalib_800x600_72;