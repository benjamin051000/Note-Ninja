library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mcu_uart_fifo is
port(
    clk, rst : in std_logic;

    uart_rx : in std_logic; -- uart incoming serial line

    read_next_uart_word : in std_logic; -- request next FIFO word
    size : out std_logic_vector(3 downto 0); -- current size of FIFO
    empty : out std_logic; -- bool if FIFO is empty
    next_word : out std_logic_vector(7 downto 0) -- FIFO output

);
end mcu_uart_fifo;

architecture default of mcu_uart_fifo is

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

    -- Signal and reg to save incoming UART byte.
	signal rx_byte : std_logic_vector(7 downto 0);
	signal received : std_logic;

begin

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
		is_receiving => open,
		is_transmitting => open,
		recv_error => open,
		rx_samples => open,
		rx_sample_countdown => open
	);

    U_FIFO: entity work.fifo 
    PORT MAP (
		clock	 => clk,
		sclr	 => rst,

		data	 => rx_byte, -- Input data comes from UART RX
		wrreq	 => received,

        rdreq	 => read_next_uart_word,
		q	     => next_word, -- output
        
		empty	 => empty,
		usedw	 => size -- number of words currently in FIFO.
	);

end default;