library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity UART_FULL_DUPLEX is
    Port (
        clk        : in  STD_LOGIC;
        -- UART pins
        UART_TX    : out STD_LOGIC;
        UART_RX    : in  STD_LOGIC;
        -- TX interface
        tx_start   : in  STD_LOGIC;
        tx_data    : in  STD_LOGIC_VECTOR(7 downto 0);
        -- RX interface
        rx_data    : out STD_LOGIC_VECTOR(7 downto 0);
        rx_ready   : out STD_LOGIC
    );
end UART_FULL_DUPLEX;
architecture Behavioral of UART_FULL_DUPLEX is
begin
    ------------------------------------------------------------------
    -- UART Transmitter Instance
    ------------------------------------------------------------------
    UART_TX_INST : entity work.UART_Tx
    port map
    (
        clk     => clk,
        start   => tx_start,
        data_in => tx_data,
        Tx      => UART_TX
    );


    ------------------------------------------------------------------
    -- UART Receiver Instance
    ------------------------------------------------------------------
    UART_RX_INST : entity work.UART_Rx
    port map
    (
        clk        => clk,
        Rx         => UART_RX,
        data_out   => rx_data,
        data_ready => rx_ready
    );


end Behavioral;