library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rect is
generic (
    -- Width and height of block.
    w : natural range 0 to 640;
    h : natural range 0 to 480;

    -- Color of block. (12-bit color: 4 bits per color)
    r, g, b : natural range 0 to 15;
    
    -- OPTIONAL:
    -- Speed (num pixels to move) for x (if rect intends to move)
    x_speed : integer := -1;
    
    -- Default locations (useful for static non-moving rects)
    x0 : natural range 0 to 640 := 640/2;
    y0 : natural range 0 to 480 := 480/2
);
port(
    clk, rst : in std_logic;

    -- Used for color output
    hcount : in natural range 0 to 640;
    vcount : in natural range 0 to 480;

    -- Update x position by its speed.
    update_x: in std_logic;
    reset_x : in std_logic;
    
    -- Update y position to a new value.
    set_y: in std_logic;
    new_y : in natural range 0 to 480;
    
    -- Enable/disable color output.
    -- show, hide : in std_logic;
    new_visible, set_visible : in std_logic;
    
    -- x and y are the top left corner of the rect.
    curr_x : out natural range 0 to 640;
    curr_y : out natural range 0 to 480;

    -- What the monitor should display for these pixels.
    -- To be combined into overall video out signal.
    color: out std_logic_vector(11 downto 0) -- 12 bits for R,G,B out
);
end rect;

-- attempt to render one rectangle.
architecture default of rect is

    constant FILLED_IN : std_logic_vector(11 downto 0) := 
          std_logic_vector(to_unsigned(r, 4)) 
        & std_logic_vector(to_unsigned(g, 4)) 
        & std_logic_vector(to_unsigned(b, 4));

    -- Black for now
    constant BLACK : std_logic_vector := std_logic_vector(to_unsigned(0, 12));

    signal x : natural range 0 to 640;
    signal y : natural range 0 to 480;

    signal visible : std_logic; -- Register to save "visible" port input.

begin

    -- Update current locations.
    curr_x <= x;
    curr_y <= y;

    -- Sequential process to update location of block.
    process(clk, rst) is
    begin
        if(rst = '1') then
            -- Reset to initial position.
            x <= x0;
            y  <= y0;
            visible <= '0'; -- Start invisible.

        elsif(rising_edge(clk)) then
            
            -- Reset x to the right of the screen (new notes)
            if(reset_x = '1') then
                x <= 640;
            end if;

            -- Update x by x_speed
            if(update_x = '1') then
                x <= x + x_speed;
            end if;

            -- Update y position
            if(set_y = '1') then
                y <= new_y;
            end if;

            -- Update visibility
            if(set_visible = '1') then
                visible <= new_visible;
            end if;

        end if;
    end process;

    -- Display rect when hcount/vcount is within its body.
    color <= FILLED_IN when (
            visible = '1' 
            and (hcount >= x and hcount < x + w) 
            and (vcount >= y and vcount < y + h)
        )
        else BLACK;

end default;
