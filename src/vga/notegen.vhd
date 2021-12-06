library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.staff_constants.all;
use work.uart_commands.all;

entity notegen is
port (
    clk, rst : in std_logic;

    hcount : in natural range 0 to 640;
    vcount : in natural range 0 to 480;
    
    uart_rx : in std_logic; -- uart incoming serial line
	uart_tx : out std_logic; -- uart outgoing serial line

    note_colors : out std_logic_vector(11 downto 0)
);
end notegen;

architecture default of notegen is
    
    --Constants------------------------------------------------------
    constant NUM_NOTES : natural := 6; -- Number of notes to render.
    

    --Type declarations-----------------------------------------------------
	type natural_array_t is array(natural range <>) of natural; -- Unconstrained array
    subtype note_array_t is natural_array_t(0 to NUM_NOTES-1);

    -- Array to hold color values from every note.
    type color_array_t is array(0 to NUM_NOTES-1) of std_logic_vector(note_colors'range);


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


    --UART/FIFO signals------------------------------------------------------
    signal fifo_get_next_word, fifo_empty : std_logic;
    signal uart_word : std_logic_vector(7 downto 0);


    --Note signals------------------------------------------------------
    -- Color range is 0-15
	constant colors_r : note_array_t := (15, 0, 0, 15, 15, 0);
	constant colors_g : note_array_t := (0, 15, 0, 15, 0, 15);
	constant colors_b : note_array_t := (0, 0, 15, 0, 15, 15);

    -- update_x updates note location based on its speed
    signal update_x : std_logic; -- Always update them all at once!
    -- reset a single note's x val to the right of the screen.
    signal reset_x : std_logic_vector(NUM_NOTES-1 downto 0);
    -- set_y sets note y-val to new_y
    signal set_y : std_logic_vector(NUM_NOTES-1 downto 0);
    signal new_y : note_array_t;

    -- set visibility on note i
    signal new_visible : std_logic;
    signal set_visible, is_visible : std_logic_vector(NUM_NOTES-1 downto 0);
    
    
    -- color array (to be reduced)
	signal note_color_arr : color_array_t;

    --UART Decode state machine signals------------------------------------
    type uart_decode_state is (IDLE_STATE, GET_NEXT_WORD_STATE, DECODE_STATE);
    signal state, next_state : uart_decode_state;
    signal save_uart_word : std_logic;
    signal uart_word_reg : std_logic_vector(uart_word'range);

begin -- default ---------------------------------------------------------

    -- Output note colors
    note_colors <= or_reduce(note_color_arr);

    U_MCU_UART_FIFO : entity work.mcu_uart_fifo
    port map (
        clk,
        rst,
        uart_rx,
        uart_tx,

        read_next_uart_word => fifo_get_next_word,
        size => open,
        empty => fifo_empty,
        next_word => uart_word
    );

    U_NOTES: for i in 0 to NUM_NOTES-1 generate
        U_NOTE: entity work.rect
        generic map(
            w => 50,
            h => NOTE_HEIGHT,

            r => colors_r(i),
            g => colors_g(i),
            b => colors_b(i),
            
            x_speed => -1
        )
        port map(
            clk,
            rst,
            hcount,
            vcount,
            
            update_x => update_x,
            reset_x => reset_x(i),

            set_y => set_y(i),
            new_y => new_y(i),

            new_visible => new_visible,
            set_visible => set_visible(i),
            is_visible => is_visible(i),

            curr_x => open, -- TODO may be unnecessary
            curr_y => open,

            color => note_color_arr(i)
        );
    end generate U_NOTES;

    -- Sequential process to execute UART commands
    U_UART_DECODE_FSM_SEQ: process(clk, rst)
    begin
        if(rst = '1') then
            state <= IDLE_STATE;

        elsif(rising_edge(clk)) then
            state <= next_state;

            if(save_uart_word = '1') then
                uart_word_reg <= uart_word;
            end if;
        end if;
    end process;

    -- State machine process
    U_UART_DECODE_FSM_COMB: process(state, fifo_empty, uart_word_reg, is_visible)
        variable new_note_pitch : natural;
        variable new_note_idx : natural;
    begin
        -- FSM defaults
        next_state <= state; -- Stay in current state.
        save_uart_word <= '0';
        fifo_get_next_word <= '0';
        
        new_note_pitch := 0;
        new_note_idx := NUM_NOTES; -- default is out of range of arrays.

        -- Decoder output defaults
        update_x <= '0';
        set_y <= (others => '0');
        new_y <= (others => 0);
        new_visible <= '0';
        set_visible <= (others => '0');
        reset_x <= (others => '0');

        case state is
            when IDLE_STATE =>
                -- if FIFO has words, get them.
                if(fifo_empty = '0') then
                    fifo_get_next_word <= '1'; -- FIFO will have this ready in 1 cycle.
                    next_state <= GET_NEXT_WORD_STATE;
                end if;
            
            when GET_NEXT_WORD_STATE =>
                -- next word is ready on uart_word. Save it into uart_word_reg.
                save_uart_word <= '1';
                next_state <= DECODE_STATE;
            
            when DECODE_STATE =>
                -- case statement to decode uart
                case uart_word_reg is
                    when ADVANCE_NOTES => -- char "A"
                        update_x <= '1';
                    
                    when CREATE_LOW_D => new_note_pitch := NOTE_LOW_D_HEIGHT;

                    when CREATE_LOW_E => new_note_pitch := NOTE_LOW_E_HEIGHT;

                    when CREATE_LOW_F => new_note_pitch := NOTE_LOW_F_HEIGHT;

                    when CREATE_LOW_G => new_note_pitch := NOTE_LOW_G_HEIGHT;

                    when CREATE_A => new_note_pitch := NOTE_A_HEIGHT;

                    when CREATE_B => new_note_pitch := NOTE_B_HEIGHT;

                    when CREATE_C => new_note_pitch := NOTE_C_HEIGHT;

                    when CREATE_HIGH_D => new_note_pitch := NOTE_HIGH_D_HEIGHT;

                    when CREATE_HIGH_E => new_note_pitch := NOTE_HIGH_E_HEIGHT;

                    when CREATE_HIGH_F => new_note_pitch := NOTE_HIGH_F_HEIGHT;

                    when CREATE_HIGH_G => new_note_pitch := NOTE_HIGH_G_HEIGHT;

                    when others => null;
                end case;
                
                -- Logic to create the new note
                if(new_note_pitch /= 0) then

                    -- First, find an invisible note.
                    for i in 0 to NUM_NOTES-1 loop
                        if(is_visible(i) = '0') then
                            -- Let's replace this one.
                            new_note_idx := i;
                        end if;
                    end loop;
                    
                    -- If the above for loop found a valid note index
                    if(new_note_idx /= NUM_NOTES) then
                        -- Reset this new note
                        new_y(new_note_idx) <= new_note_pitch;
                        set_y(new_note_idx) <= '1';
                        reset_x(new_note_idx) <= '1';
                        new_visible <= '1'; -- visible val to be saved
                        set_visible(new_note_idx) <= '1'; -- save visible val
                    end if;
                end if;
                
                next_state <= IDLE_STATE;

            when others => null;
        end case;
    end process;

end architecture; -- default