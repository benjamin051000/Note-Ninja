library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rect is
generic (
    -- REQUIRED
    -- Width and height of block.
    w : natural range 0 to 640;
    h : natural range 0 to 480;

    -- OPTIONAL
    -- Initial position
    x0 : natural range 0 to 640 := 640/2;
    y0 : natural range 0 to 480 := 480/2;

    -- Color of block. (12-bit color: 4 bits per color)
    r : natural range 0 to 15 := 0;
    g : natural range 0 to 15 := 15;
    b : natural range 0 to 15 := 15
);
port(
    clk, rst : in std_logic;
    
    hcount : in natural range 0 to 640;
    vcount : in natural range 0 to 480;

    -- Send an update to the x, y location
    update: in std_logic;
    new_x, new_y : in natural range 0 to 640;
    
    -- What the monitor should display. 
    -- To be combined into overall video out signal.
    color: out std_logic_vector(11 downto 0) -- 12 bits for R,G,B out
);
end rect;

-- attempt to render one rectangle.
architecture default of rect is

    -- x and y represent the top left corner of the rect.
    signal x, y : natural range 0 to 640;

    constant FILLED_IN : std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(r, 4)) & std_logic_vector(to_unsigned(g, 4)) & std_logic_vector(to_unsigned(b, 4));

    -- Black for now
    constant BLACK : std_logic_vector := std_logic_vector(to_unsigned(0, 12));

begin

-- Sequential process to update location of block.
process(clk, rst) is
begin
    if(rst = '1') then
        -- Reset to initial position.
        x <= x0;
        y <= y0;
    elsif(rising_edge(clk)) then
        if(update = '1') then
            x <= new_x;
            y <= new_y;
        end if;
    end if;
end process;

-- Combinational logic to display block when 
-- hcount/vcount is within the block body.
color <= FILLED_IN when (
        -- Relational ops are evaluated before logical ops! No extra ()s needed.
        (hcount >= x and hcount < x + w) and (vcount >= y and vcount < y + h)
    ) 
    else BLACK;

end default;
