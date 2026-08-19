library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_FULL_DUPLEX_tb is
end UART_FULL_DUPLEX_tb;

architecture sim of UART_FULL_DUPLEX_tb is

    --------------------------------------------------------------------
    -- Signals
    --------------------------------------------------------------------
    signal clk      : std_logic := '0';
    signal tx_start : std_logic := '0';
    signal tx_data  : std_logic_vector(7 downto 0) := (others => '0');
    signal uart_tx  : std_logic;
    signal uart_rx  : std_logic;
    signal rx_data  : std_logic_vector(7 downto 0);
    signal rx_ready : std_logic;

    --------------------------------------------------------------------
    -- Clock
    --------------------------------------------------------------------
    constant CLK_PERIOD : time := 10 ns;

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    DUT : entity work.UART_FULL_DUPLEX
        port map (
            clk      => clk,
            UART_TX  => uart_tx,
            UART_RX  => uart_rx,
            tx_start => tx_start,
            tx_data  => tx_data,
            rx_data  => rx_data,
            rx_ready => rx_ready
        );

    --------------------------------------------------------------------
    -- Loopback
    --------------------------------------------------------------------
    uart_rx <= uart_tx;

    --------------------------------------------------------------------
    -- Clock Generation (100 MHz)
    --------------------------------------------------------------------
    clk <= not clk after CLK_PERIOD/2;

    --------------------------------------------------------------------
    -- Test Process
    --------------------------------------------------------------------
    process
    begin

        wait for 200 ns;

        ----------------------------------------------------------------
        -- Test 1 : Send 0xA5
        ----------------------------------------------------------------
        report "--------------------------------";
        report "Sending 0xA5";

        tx_data  <= x"A5";
        tx_start <= '1';
        wait for CLK_PERIOD;
        tx_start <= '0';

        wait until rx_ready = '1' for 2 ms;

        assert rx_ready = '1'
            report "ERROR: Timeout waiting for reception."
            severity failure;

        assert rx_data = x"A5"
            report "ERROR: Expected 165, Received "
                   & integer'image(to_integer(unsigned(rx_data)))
            severity error;

        report "PASS: Received 0xA5";

        wait until rx_ready = '0';

        ----------------------------------------------------------------
        -- Delay
        ----------------------------------------------------------------
        wait for 100 us;

        ----------------------------------------------------------------
        -- Test 2 : Send 0xB5
        ----------------------------------------------------------------
        report "--------------------------------";
        report "Sending 0xB5";

        tx_data  <= x"B5";
        tx_start <= '1';
        wait for CLK_PERIOD;
        tx_start <= '0';

        wait until rx_ready = '1' for 2 ms;

        assert rx_ready = '1'
            report "ERROR: Timeout waiting for reception."
            severity failure;

        assert rx_data = x"B5"
            report "ERROR: Expected 181, Received "
                   & integer'image(to_integer(unsigned(rx_data)))
            severity error;

        report "PASS: Received 0xB5";

        wait until rx_ready = '0';

        ----------------------------------------------------------------
        -- End Simulation
        ----------------------------------------------------------------
        report "==========================================";
        report " ALL UART LOOPBACK TESTS PASSED SUCCESSFULLY ";
        report "==========================================";

        wait;

    end process;

end sim;